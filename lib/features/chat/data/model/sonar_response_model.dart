
class SonarResponse {
    final String id;
    final String model;
    final int created;
    final Usage usage;
    final List<dynamic> citations;
    final String object;
    final List<Choice> choices;

    SonarResponse({
        required this.id,
        required this.model,
        required this.created,
        required this.usage,
        required this.citations,
        required this.object,
        required this.choices,
    });

    factory SonarResponse.fromJson(Map<String, dynamic> json) => SonarResponse(
        id: json["id"],
        model: json["model"],
        created: json["created"],
        usage: Usage.fromJson(json["usage"]),
        citations: List<dynamic>.from(json["citations"].map((x) => x)),
        object: json["object"],
        choices: List<Choice>.from(json["choices"].map((x) => Choice.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "model": model,
        "created": created,
        "usage": usage.toJson(),
        "citations": List<dynamic>.from(citations.map((x) => x)),
        "object": object,
        "choices": List<dynamic>.from(choices.map((x) => x.toJson())),
    };
}

class Choice {
    final int index;
    final String finishReason;
    final Delta message;
    final Delta delta;

    Choice({
        required this.index,
        required this.finishReason,
        required this.message,
        required this.delta,
    });

    factory Choice.fromJson(Map<String, dynamic> json) => Choice(
        index: json["index"],
        finishReason: json["finish_reason"],
        message: Delta.fromJson(json["message"]),
        delta: Delta.fromJson(json["delta"]),
    );

    Map<String, dynamic> toJson() => {
        "index": index,
        "finish_reason": finishReason,
        "message": message.toJson(),
        "delta": delta.toJson(),
    };
}

class Delta {
    final String role;
    final String content;

    Delta({
        required this.role,
        required this.content,
    });

    factory Delta.fromJson(Map<String, dynamic> json) => Delta(
        role: json["role"],
        content: json["content"],
    );

    Map<String, dynamic> toJson() => {
        "role": role,
        "content": content,
    };
}

class Usage {
    final int promptTokens;
    final int completionTokens;
    final int totalTokens;
    final String searchContextSize;

    Usage({
        required this.promptTokens,
        required this.completionTokens,
        required this.totalTokens,
        required this.searchContextSize,
    });

    factory Usage.fromJson(Map<String, dynamic> json) => Usage(
        promptTokens: json["prompt_tokens"],
        completionTokens: json["completion_tokens"],
        totalTokens: json["total_tokens"],
        searchContextSize: json["search_context_size"],
    );

    Map<String, dynamic> toJson() => {
        "prompt_tokens": promptTokens,
        "completion_tokens": completionTokens,
        "total_tokens": totalTokens,
        "search_context_size": searchContextSize,
    };
}
