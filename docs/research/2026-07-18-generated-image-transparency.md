# Generated-image transparency and provenance

- **Research date:** 2026-07-18
- **Research agent test:** Passed
- **Question:** What transparency and provenance practices should MoodX follow
  when publishing Gemini-generated images in a public pitch deck?
- **Scope:** Current official Gemini terms and documentation, C2PA provenance,
  NIST guidance, and the EU AI Act. This is not legal advice.

## Verified findings

- Gemini-generated images include an invisible SynthID watermark. Detection can
  be inconclusive, and editing can make the watermark undetectable.
- Google's prohibited-use policy forbids deceptively presenting generated
  content as solely human-created.
- Gemini API users remain responsible for lawful use and any attribution that
  may be required.
- C2PA Content Credentials can bind origin, edits, and AI involvement to an
  asset, but provenance can be removed and does not prove that depicted content
  is factually true.
- NIST treats watermarking, metadata, digital fingerprints, and human review as
  complementary mechanisms whose limitations should be documented.
- EU AI Act Article 50 transparency obligations apply from 2026-08-02 in
  relevant EU contexts. Whether a particular MoodX visual is covered depends on
  its content, audience, and distribution.

## MoodX implications

1. Add a visible deck-level disclosure: “Selected visuals were generated with
   AI and reviewed by the MoodX team.”
2. Add image-level labels when concept art or mockups could be mistaken for real
   people, events, products, evidence, or implemented UI.
3. Preserve original output, prompt, model, generation time, later edits, and a
   SHA-256 digest in the repository.
4. Treat SynthID or Content Credentials as supporting provenance, not proof of
   factual truth or rights clearance.
5. Require human review for misleading claims, trademarks, recognizable people,
   confidential inputs, bias, and visible defects before publication.

## Open questions

- Where and when will the deck be publicly distributed?
- Will generated visuals depict real people, places, products, or MoodX UI?
- Will the final export preserve machine-readable provenance?
- Who owns final visual publication approval?

## Primary sources

- [Gemini image-generation documentation](https://ai.google.dev/gemini-api/docs/generate-content/image-generation?hl=en)
- [Gemini verification help](https://support.google.com/gemini/answer/16722517?hl=en)
- [Gemini API Additional Terms](https://ai.google.dev/gemini-api/terms)
- [Google Generative AI Prohibited Use Policy](https://policies.google.com/terms/generative-ai/use-policy?gl=US&hl=en-US)
- [C2PA 2.2 explainer](https://c2pa.org/specifications/specifications/2.2/explainer/Explainer.html)
- [NIST AI 600-1](https://nvlpubs.nist.gov/nistpubs/ai/NIST.AI.600-1.pdf)
- [EU AI Act](https://eur-lex.europa.eu/legal-content/en/TXT/?uri=CELEX%3A32024R1689)
