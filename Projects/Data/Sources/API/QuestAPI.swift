enum QuestAPI: BaseAPI {
    case list
    case claim(questId: String, request: ClaimQuestRequestDTO)

    var path: String {
        switch self {
        case .list:  "/api/quests"
        case .claim: "/api/quests/{id}/claim"
        }
    }

    var pathParameters: [String: String] {
        switch self {
        case .list:                        [:]
        case .claim(let questId, _):       ["id": questId]
        }
    }

    var method: HTTPMethod {
        switch self {
        case .list:  .get
        case .claim: .post
        }
    }

    var authorization: AuthorizationPolicy {
        switch self {
        case .list:  .optional
        case .claim: .required
        }
    }

    var task: RequestTask {
        switch self {
        case .list:                       .plain
        case .claim(_, let request):      .jsonBody(request)
        }
    }
}
