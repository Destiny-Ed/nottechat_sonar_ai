# NotteChat: AI-Powered Document Chat with Perplexity Sonar API

**Perplexity Hackathon Submission – AI and Machine Learning Category**

NotteChat is an innovative Flutter app that transforms how users interact with documents. By pasting URLs for Word (.doc, .docx), PDF, or Google Docs, users can extract text and engage in AI-powered chats about the content. For the Perplexity Hackathon, we integrated the Perplexity Sonar API to summarize documents and answer queries with real-time, cited responses, enhancing NotteChat’s educational and productivity value. With offline .doc support and real filename extraction, NotteChat democratizes access to knowledge for students, educators, and professionals.

## Project Overview

NotteChat enables users to paste document URLs, extract text, and chat with an AI to summarize, analyze, or explore content. The app supports legacy Word (.doc), modern Word (.docx), PDF, and Google Docs URLs, with offline text extraction for .doc files and real filename display (e.g., “Session 2025-11-13 - ProjectProposal.pdf”). Integrated with the Perplexity Sonar API, NotteChat now provides concise document summaries and context-aware answers, making it a powerful tool for learning and research.

## Features

- **Document URL Processing**: Paste .doc, .docx, PDF, or Google Docs URLs to extract text instantly.
- **Offline .doc Support**: Parse legacy .doc files client-side using a custom binary parser, no internet required.
- **Real Filename Extraction**: Display accurate document names from Content-Disposition headers or Google Docs metadata.
- **AI-Powered Chat**: Summarize documents and answer queries using the Perplexity Sonar API, with cited responses.
- **Cross-Platform**: Built with Flutter for seamless performance on iOS, Android, and web.
- **Polished UX**: Vibrant UI with intuitive onboarding, session naming, and a 3-day free trial paywall ($4.99/month after).
- **Analytics**: Firebase integration tracks document types and API usage for continuous improvement.

## Functionality

**URL Input**: Users paste a document URL in the chat dialog (e.g., https://example.com/sample.doc or a Google Docs link).  
**Text Extraction**:
- `.doc`: Offline binary parser extracts ASCII text.
- `.docx`: XML parsing via archive and xml packages.
- `PDF`: Text extraction with syncfusion_flutter_pdf.
- `Google Docs`: PDF export with real filename extraction.

**AI Chat**: Users ask questions (e.g., “Summarize this PDF” or “Compare this .doc to current trends”). The Perplexity Sonar API processes the query with extracted text as context, delivering summaries or answers with web-sourced citations.  
**Session Management**: Chats are organized with descriptive titles (e.g., “Session 2025-11-13 - SampleReport.doc”).  
**Error Handling**: User-friendly errors suggest converting unsupported .doc files to .docx or PDF externally.

## Perplexity Sonar API Integration

The Perplexity Sonar API powers NotteChat’s chat functionality, replacing our previous Gemini AI integration for document summarization and query answering. Similar to how we used Gemini AI to generate concise document summaries, Sonar API processes extracted document text (up to 4,000 characters) to provide:

- **Document Summarization**: Users request summaries (e.g., “Summarize this research paper”), and Sonar delivers clear, concise overviews, leveraging its quick search mode for efficiency.
- **Context-Aware Answers**: For queries like “What are the key points of this .doc?”, Sonar uses the document text as context, ensuring relevant responses.
- **Real-Time Research**: For broader questions (e.g., “How does this PDF align with 2025 trends?”), Sonar’s real-time internet search fetches up-to-date information, with citations for credibility.
- **Reasoning Mode**: Complex queries (e.g., “Analyze the implications of this report”) use Sonar Reasoning for chain-of-thought responses, enhancing depth.

The API is integrated via a `SonarService` class, which sends HTTP POST requests to Sonar’s endpoint with the document text and user query. Responses include citations, displayed below answers for transparency. Firebase analytics track API usage (e.g., query type, success rate), ensuring robust performance.

## Developer Tools

NotteChat was built with the following tools, meeting Perplexity Hackathon requirements:

- **Flutter**: Cross-platform framework for iOS, Android, and web.
- **Dart**: Programming language for NotteChat’s logic, including offline .doc parsing.
- **Perplexity Sonar API**: AI answer engine for document summarization and query answering.
- **Firebase**: Analytics for tracking document types and API usage.

**Packages**:
- `http`: For fetching document URLs and Sonar API requests.
- `syncfusion_flutter_pdf`: PDF text extraction.
- `archive` and `xml`: .docx parsing.
- `path_provider`: Temporary file storage.

**IDEs & Repositories**:
- **VS Code**: Primary IDE for development and debugging.
- **GitHub**: Version control for the private repository.

## Project Requirements

NotteChat meets the Perplexity Hackathon’s requirements:

- **Internet-Enabled**: Fetches document URLs and uses Sonar API for real-time, cited answers.
- **Knowledge-Seeking**: Enables users to explore document content through AI-driven summaries and queries, fostering curiosity and learning.
- **AI and Machine Learning Category**: Leverages Sonar API’s machine learning capabilities for document summarization and reasoning.
- **New or Updated**: The Sonar API integration and citation display were added specifically for the hackathon, building on NotteChat’s existing document processing.

## Installation and Setup

**Clone the Repository**:
```bash
git clone https://github.com/Destiny-Ed/nottechat_sonar_ai.git
```
(Repo shared with james.liounis@perplexity.ai and testing@devpost.com)

**Install Dependencies**:
```bash
cd nottechat_sonar_ai
flutter pub get
```

**Configure Firebase**:
- Set up a Firebase project and add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) to the project.
- Enable Firebase Analytics.

**Add Sonar API Key**:
Create a `lib/core/constant.dart` file:
```dart
const String sonarApiKey = 'YOUR_PERPLEXITY_API_KEY';
```
Obtain the key from [https://www.perplexity.ai/api](https://www.perplexity.ai/api).

**Run the App**:
```bash
flutter run
```

## Usage

1. Launch NotteChat and navigate to the chat screen.
2. Paste a document URL (e.g., https://example.com/sample.doc or a Google Docs link).
3. View the session title with the real filename (e.g., “SampleReport.doc”).
4. Ask questions like “Summarize this PDF” or “What’s new in this field?” to get Sonar-powered responses with citations.


## Demonstration Video

Watch our 3-minute demo showcasing NotteChat’s document processing and Sonar API integration:  
[Insert Video URL: e.g., https://www.youtube.com/watch?v=XXXXXXX]  
Note: Video will be uploaded to YouTube (public) by May 28, 2025, and shared with judges.

## Code Repository

Private GitHub repository for judging and testing:  
[Private Repo URL: e.g., https://github.com/Destiny-Ed/nottechat_sonar_ai.git]
Note: Access granted to james.liounis@perplexity.ai and testing@devpost.com.

## Future Enhancements

- **Unicode .doc Parsing**: Enhance the .doc parser to support Unicode text for broader compatibility.
- **Local File Upload**: Allow users to upload local .doc, .docx, and PDF files alongside URLs.
- **Sonar Deep Research**: Integrate Sonar’s Deep Research mode for in-depth analysis of complex documents.
- **Caching**: Store Sonar API responses locally to reduce latency for repeated queries.

## Team

- **Dikeocha Destiny**: Lead developer, responsible for Flutter implementation, Sonar API integration, and UI design.

## Contact

For questions or feedback, reach out at [talk2destinyed@gmail], [dikeachaeze@gmail.com]

## Acknowledgments

Thank you to Perplexity AI for the Sonar API and hackathon opportunity. NotteChat is inspired by the mission to make knowledge accessible and engaging for all.

#NotteChat #PerplexityHackathon #AI
