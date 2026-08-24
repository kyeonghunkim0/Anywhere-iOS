//
//  NavigationCoordinator.swift
//  Presentation
//
//  화면 전환을 한 곳에서 관리한다. View는 "어디로 간다"만 알고,
//  스택을 어떻게 쌓고 무엇을 띄우는지는 코디네이터가 소유한다.
//
//  NavigationPath 대신 [Route] 배열을 쓴다 — 현재 스택을 타입 그대로 읽을 수 있어
//  popToRoot/특정 화면까지 되돌리기 같은 조작을 그대로 표현할 수 있다.
//

import Foundation
import Observation

@MainActor
@Observable
public final class NavigationCoordinator {
    public enum PresentationStyle: Sendable {
        case sheet
        case fullScreenCover
    }

    /// NavigationStack에 바인딩되는 푸시 스택.
    public var path: [Route] = []
    /// 시트로 떠 있는 화면. 사용자가 끌어내려 닫는 경우가 있어 View에서 쓰기 가능해야 한다.
    public var sheet: Route?
    /// 전체 화면으로 떠 있는 화면.
    public var fullScreenCover: Route?

    public init() {}

    public var currentRoute: Route? { path.last }

    // MARK: - Push

    public func pushViewController(_ route: Route) {
        path.append(route)
    }

    // MARK: - Pop

    @discardableResult
    public func popViewController() -> Route? {
        path.isEmpty ? nil : path.removeLast()
    }

    /// 지정한 개수만큼 되돌린다. 스택보다 큰 값이 들어오면 루트까지만 간다.
    public func popViewController(count: Int) {
        guard count > 0 else { return }
        path.removeLast(min(count, path.count))
    }

    /// 스택에 있는 특정 화면까지 되돌린다. 없으면 아무것도 하지 않는다.
    public func popViewController(to route: Route) {
        guard let index = path.lastIndex(of: route) else { return }
        path.removeSubrange(path.index(after: index)...)
    }

    public func popToRootViewController() {
        path.removeAll()
    }

    // MARK: - Present

    public func present(_ route: Route, style: PresentationStyle = .sheet) {
        switch style {
        case .sheet:
            sheet = route
        case .fullScreenCover:
            fullScreenCover = route
        }
    }

    /// 떠 있는 시트/전체 화면을 닫는다. 둘 다 없으면 무시된다.
    public func dismiss() {
        sheet = nil
        fullScreenCover = nil
    }

    /// 떠 있는 화면을 닫고 스택도 루트로 되돌린다 — 로그아웃처럼 세션이 바뀔 때 쓴다.
    public func reset() {
        dismiss()
        popToRootViewController()
    }
}
