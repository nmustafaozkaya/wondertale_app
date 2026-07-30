const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { defineSecret } = require("firebase-functions/params");
const admin = require("firebase-admin");

admin.initializeApp();

const geminiApiKeySecret = defineSecret("GEMINI_API_KEY");

// Allowed options for strict safety validation
const ALLOWED_AGES = ["2-4", "5-7", "8-10"];
const ALLOWED_THEMES = ["space", "forest", "underwater", "kingdom", "dinosaurs"];
const ALLOWED_MOODS = ["calming", "fun", "courage", "sharing"];
const ALLOWED_LANGS = ["tr", "en"];

exports.generateStory = onCall({ secrets: [geminiApiKeySecret] }, async (request) => {
  // Validate Authentication if required
  const uid = request.auth ? request.auth.uid : "anonymous_user";

  const { ageGroup, theme, mood, childName: rawChildName, language = "tr" } = request.data || {};

  // 1. Strict Input Sanitization & Validation
  const sanitizedAge = ALLOWED_AGES.includes(ageGroup) ? ageGroup : "5-7";
  const sanitizedTheme = ALLOWED_THEMES.includes(theme) ? theme : "forest";
  const sanitizedMood = ALLOWED_MOODS.includes(mood) ? mood : "calming";
  const sanitizedLang = ALLOWED_LANGS.includes(language) ? language : "tr";

  // Child name max 30 chars, strip illegal symbols
  let childName = "";
  if (typeof rawChildName === "string") {
    childName = rawChildName.trim().substring(0, 30).replace(/[^a-zA-Z0-9çğıöşüÇĞİÖŞÜ\s]/g, "");
  }

  const apiKey = geminiApiKeySecret.value() || process.env.GEMINI_API_KEY;

  if (!apiKey) {
    throw new HttpsError("failed-precondition", "GEMINI_API_KEY is not configured in Firebase Secret Manager.");
  }

  // 2. Build Safety Prompt System Instruction
  const systemInstruction = 
    "You are a warm, imaginative children's book author writing delightful, safe, and educational bedtime stories for kids. " +
    "CRITICAL MANDATE: Content MUST be 100% wholesome, gentle, and non-violent. Never include scary elements, violence, harassment, or adult themes. " +
    "Output must be valid raw JSON with keys 'title', 'content', and 'illustrationPrompt'. Do not include markdown code block formatting like ```json.";

  const isTurkish = sanitizedLang === "tr";

  const themeText = {
    space: isTurkish ? "Uzay Macera" : "Outer Space Adventure",
    forest: isTurkish ? "Büyülü Orman" : "Enchanted Forest",
    underwater: isTurkish ? "Deniz Altı Dünyası" : "Underwater Realm",
    kingdom: isTurkish ? "Büyülü Krallık" : "Magical Kingdom",
    dinosaurs: isTurkish ? "Sevimli Dinozorlar" : "Friendly Dinosaurs",
  }[sanitizedTheme];

  const moodText = {
    calming: isTurkish ? "Sakinleştirici ve rahatlatıcı" : "Calming and relaxing bedtime story",
    fun: isTurkish ? "Neşeli ve komik" : "Fun, cheerful, and lighthearted",
    courage: isTurkish ? "Cesaret ve özgüven aşılayan" : "Inspiring courage and confidence",
    sharing: isTurkish ? "Paylaşmayı ve dostluğu öğreten" : "Teaching sharing, kindness, and friendship",
  }[sanitizedMood];

  const promptText = `
Target Age Group: ${sanitizedAge} years old.
Story Theme: ${themeText}
Mood/Goal: ${moodText}
Language: ${isTurkish ? "Turkish (Türkçe)" : "English"}
${childName ? `Main Character Name: "${childName}"` : "Main Character: A curious, friendly child hero"}

Please write an engaging, beautiful children's story (around 250-400 words) divided into clear, readable paragraphs.
Return JSON format strictly:
{
  "title": "Title of story in ${sanitizedLang}",
  "content": "Full story body in ${sanitizedLang}",
  "illustrationPrompt": "Detailed English prompt for a cute watercolor children's book illustration depicting the hero in the main scene"
}
`;

  try {
    // 3. Request Gemini API (gemini-3.5-flash-lite or gemini-2.0-flash endpoint)
    const textModelName = "gemini-2.0-flash"; // Compatible Flash endpoint
    const textUrl = `https://generativelanguage.googleapis.com/v1beta/models/${textModelName}:generateContent?key=${apiKey}`;

    const textRequestBody = {
      contents: [
        {
          role: "user",
          parts: [{ text: promptText }]
        }
      ],
      systemInstruction: {
        parts: [{ text: systemInstruction }]
      },
      safetySettings: [
        { category: "HARM_CATEGORY_HARASSMENT", threshold: "BLOCK_LOW_AND_ABOVE" },
        { category: "HARM_CATEGORY_HATE_SPEECH", threshold: "BLOCK_LOW_AND_ABOVE" },
        { category: "HARM_CATEGORY_SEXUALLY_EXPLICIT", threshold: "BLOCK_LOW_AND_ABOVE" },
        { category: "HARM_CATEGORY_DANGEROUS_CONTENT", threshold: "BLOCK_LOW_AND_ABOVE" }
      ],
      generationConfig: {
        responseMimeType: "application/json",
        temperature: 0.7,
        maxOutputTokens: 1500
      }
    };

    const textResponse = await fetch(textUrl, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(textRequestBody)
    });

    if (!textResponse.ok) {
      const errText = await textResponse.text();
      console.error("Gemini API Error:", errText);
      throw new HttpsError("internal", "Failed to generate story text from Gemini API.");
    }

    const textData = await textResponse.json();
    const rawResponseText = textData.candidates?.[0]?.content?.parts?.[0]?.text || "{}";

    let storyJson;
    try {
      storyJson = JSON.parse(rawResponseText);
    } catch (e) {
      // Fallback clean parsing if code blocks exist
      const cleaned = rawResponseText.replace(/```json/g, "").replace(/```/g, "").trim();
      storyJson = JSON.parse(cleaned);
    }

    // 4. Generate Illustration via Image API (gemini-3.1-flash-image / Imagen / Gemini multimodal prompt)
    let imageBase64 = null;
    try {
      const imgPrompt = storyJson.illustrationPrompt || `Cute pastel watercolor illustration of ${themeText} for children's storybook`;
      const imgModelName = "imagen-3.0-generate-002"; 
      const imgUrl = `https://generativelanguage.googleapis.com/v1beta/models/${imgModelName}:predict?key=${apiKey}`;

      const imgResponse = await fetch(imgUrl, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          instances: [{ prompt: `${imgPrompt}, children's book cover style, vibrant soft colors, high quality digital artwork` }],
          parameters: { sampleCount: 1, aspectRatio: "1:1", outputOptions: { mimeType: "image/jpeg" } }
        })
      });

      if (imgResponse.ok) {
        const imgData = await imgResponse.json();
        imageBase64 = imgData.predictions?.[0]?.bytesBase64Encoded || null;
      }
    } catch (imgErr) {
      console.warn("Illustration generation skipped or optional:", imgErr.message);
    }

    // 5. Build Result Payload
    const storyResult = {
      id: "story_" + Date.now() + "_" + Math.random().toString(36).substr(2, 5),
      title: storyJson.title || (isTurkish ? "Büyülü Masal" : "Magical Story"),
      content: storyJson.content || "",
      illustrationPrompt: storyJson.illustrationPrompt || "",
      imageBase64: imageBase64,
      theme: sanitizedTheme,
      mood: sanitizedMood,
      ageGroup: sanitizedAge,
      childName: childName,
      language: sanitizedLang,
      createdAt: new Date().toISOString()
    };

    return storyResult;
  } catch (error) {
    console.error("Cloud Function generateStory Error:", error);
    throw new HttpsError("internal", error.message || "An unexpected error occurred during story creation.");
  }
});
