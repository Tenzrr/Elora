# Class Descriptions

These descriptions explain the responsibilities of the classes shown in the six class diagrams. A class may appear in more than one diagram because each diagram presents a different part of the system. Repeated classes are described once below; the relationships specific to each diagram are listed afterward. Attributes and operations shown in the diagrams are simplified to keep the diagrams readable.

## 1. System Overview

| Class | Description |
|---|---|
| **User** | Represents a person using the application. The class stores the user's identifier and name and provides the operation to create a plant profile. A user can own multiple plants, submit analysis sessions, start conversations, and publish community posts. |
| **Plant** | Represents a crop or plant registered by a user. It stores an identifier, crop type, and nickname, and can record a plant log. A plant may have multiple logs and care recommendations and may be linked to analysis sessions. |
| **PlantLog** | Represents a dated diary entry or activity recorded for a plant. It stores the entry type and time and provides an operation to record the entry. Its lifecycle is tied to its plant. |
| **AnalysisSession** | Represents one image-analysis request. It records the crop, analysis task, and model used, and can be marked complete. A session may be associated with a plant and may contain one analysis result. |
| **AnalysisResult** | Represents the general outcome of an analysis. It stores a predicted label and confidence value and can provide related guidance. A session produces at most one result in this overview. |
| **CareRecommendation** | Represents practical care advice associated with a plant. In the overview it stores a type and description and can be scheduled. The predictive-farming diagram shows the action and reason for a recommendation. |
| **Conversation** | Represents a conversation started by a user with the application's assistant. It provides an operation for sending a message and contains one or more messages. |
| **Message** | Represents one message in a conversation. It stores the sender's role and message content and provides an operation to display the message. |
| **CommunityPost** | Represents content published by a user to the community. In the overview it stores an identifier and caption and provides an operation to publish the post. The community diagram expands this class with crop, title, and content details. |

## 2. Crop Health Analysis

| Class | Description |
|---|---|
| **CropType** *(enumeration)* | Lists the crop categories supported by the system: tomato, chilli, citrus, banana, roses, and chrysanthemum. It helps the analysis service select a suitable crop model. |
| **ScanCameraScreen** | Represents the screen where a user captures a new crop image or selects an existing image. It sends the selected image to the crop-health controller. |
| **CropHealthController** | Coordinates crop-health requests from the screen. It asks the crop-health service to analyze an image, retrieves scan history, and saves the resulting analysis session. |
| **CropHealthService** | Performs the crop-health analysis workflow. It analyzes an image for a selected crop, chooses a compatible model, and creates a recovery plan from a detection. |
| **CropModel** *(interface)* | Defines the prediction operation that crop-specific disease models must provide. The interface accepts a crop type and supports the listed crop categories. |
| **DiseaseDetection** | Stores the disease label, confidence, and severity returned by a scan. It can provide guidance and is stored as the result of an analysis session. |
| **RecoveryPlan** | Represents the recommended course of action for a disease detection. It stores advisory information and provides access to its ordered recovery steps. |
| **RecoveryStep** | Represents one action within a recovery plan. It stores its order, action, and details and can be marked complete. A recovery plan contains one or more steps. |

**Relationships in this diagram:** The screen sends an image to the controller, which requests analysis from the service. The service selects a crop model and creates a recovery plan. The controller saves the scan as an analysis session; a session may be linked to a plant and may contain one disease detection. Each recovery plan contains one or more recovery steps.

## 3. Produce Quality Assessment

| Class | Description |
|---|---|
| **QualityScanScreen** | Represents the screen used to capture or select an image of produce for quality assessment. It sends the image to the quality controller. |
| **QualityController** | Coordinates quality-assessment requests. It asks the quality service to grade produce and saves the assessment in an analysis session. |
| **QualityService** | Performs the produce-grading workflow for a selected crop. It selects a compatible crop model and can recommend when the produce should be harvested. |
| **QualityAssessment** | Stores the quality grade, ripeness, percentage of visible defects, and estimated shelf life produced by an assessment. An analysis session may contain one quality assessment. |

**Relationships in this diagram:** The screen sends an image to the controller, which requests grading from the service. The service selects a crop model. The controller saves the assessment in an analysis session, which may be associated with a plant and stores the assessment result. The shared `CropType` enumeration and `CropModel` interface are also used here.

## 4. Predictive Farming

| Class | Description |
|---|---|
| **CommunityPost** | Supplies community content that may describe a disease seen by a grower. A post may include one structured community disease report. |
| **CommunityDiseaseReport** | Represents crop-disease information reported by a community post. It stores the crop, reported disease, and area so the predictive service can consider reports from nearby farms. |
| **CommunityReportProvider** *(interface)* | Defines the operation used to retrieve community disease reports. The predictive-farming service uses this interface to access community data without depending on the community module's internal implementation. |
| **WeatherProvider** *(external service)* | Represents the external weather source. It provides forecast data used by predictive-farming and irrigation advice. |
| **WeatherSnapshot** | Represents the weather conditions returned by the provider, including temperature, humidity, and rainfall. Predictive-farming and irrigation logic use this information when producing advice. |
| **PredictiveFarmingService** | Combines local plant information, community disease reports, and weather conditions to estimate risk and create farming advice. It can also issue alerts for nearby farms when community reports indicate a local disease risk. |
| **FarmRiskAlert** | Represents a disease-risk alert delivered to a user. It stores the affected crop and disease, the assessed risk level, and the alert radius. |
| **IrrigationSchedule** | Represents a recommended watering schedule for a plant. It stores the recommended time, water volume, and schedule status and uses weather forecasts to inform the schedule. |

**Relationships in this diagram:** Users own plants and share community posts. A post may contain a disease report, which the report-provider interface makes available to the predictive-farming service. The service checks nearby plants, uses weather data, creates advice, and issues risk alerts to users. Plants may have multiple irrigation schedules, which use weather snapshots and explain their recommended action through care recommendations.

## 5. Agricultural Assistant

| Class | Description |
|---|---|
| **AgentThread** | Represents a conversation session with the agricultural assistant. It stores an identifier, title, and update time, and contains messages and records of tool executions. An optional plant can provide context for the thread. |
| **AgentMessage** | Represents a message in an assistant thread. It stores the sender, content, and creation time. A thread contains one or more messages. |
| **AgentToolRun** | Records a tool invoked during an assistant conversation. It stores the tool name, execution duration, and time of execution. A thread can record multiple tool runs. |
| **AgentMemory** | Represents stored agricultural knowledge or conversation memory used to provide relevant context. It stores a category, crop, and content. |
| **AssistantService** | Handles incoming assistant messages and checks the generated reply before it is returned. It coordinates the agent workflow. |
| **AgentWorkflow** | Determines the user's intent and coordinates the steps needed to form a reply. It can invoke backend tools and retrieve contextual knowledge. |
| **BackendTool** *(interface)* | Defines a common execution operation for backend tools. The workflow invokes implementations through this interface; a tool can read a plant's history. |
| **KnowledgeRetriever** | Searches stored agent memory and ranks the retrieved sources so the workflow can use relevant information in its reply. |

**Relationships in this diagram:** A user starts assistant threads, and a plant may provide context. Each thread contains messages and records tool runs. The assistant service coordinates the workflow, which invokes backend tools and the knowledge retriever. The retriever searches agent memory.

## 6. Community and Accounts

| Class | Description |
|---|---|
| **AccountService** | Handles account registration, authentication, and profile updates for users. |
| **CommunityPost** | Represents a post published by a user. It stores the crop, title, and content and provides an operation to publish it. A post can contain comments and likes. |
| **CommunityComment** | Represents a user's comment on a community post. It stores the comment text and creation time and provides an operation to submit it. Its associated post contains it. |
| **CommunityLike** | Represents a user's like on a community post. It stores when the like was created and provides an operation to add the like. Its associated post receives it. |
| **CommunityService** | Provides community functions such as retrieving the feed, creating posts, and adding comments. It manages posts and applies feed filters. |
| **FeedFilter** | Represents criteria for retrieving a portion of the community feed. It stores the crop filter, result limit, and offset and provides an operation to apply those criteria. |

**Relationships in this diagram:** The account service manages user accounts. Users author posts and are associated with their comments and likes. Posts contain comments and receive likes. The community service manages posts and applies a feed filter.

## Notes for the Report

- A class diagram may show only the attributes and operations relevant to that view. For example, `CommunityPost` is simplified in the system overview and expanded in the community and predictive-farming diagrams.
- `+` before a field or operation in the diagrams denotes public visibility.
- The `<<interface>>` and `<<enumeration>>` labels identify interfaces and enumerations. The `<<external>>` label identifies the weather provider as an external service.
