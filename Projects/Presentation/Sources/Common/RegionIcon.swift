//
//  RegionIcon.swift
//  Presentation
//
//  서버는 지역별 아이콘을 주지 않는다. 같은 지역이 어느 화면에서나 같은 그림을
//  갖도록, regionId로 고정 해시를 만들어 지역 아이콘 세트에서 고른다.
//  서버가 아이콘 키를 내려주기 시작하면 이 파일만 지우면 된다.
//

import UIComponents

extension String {
    var regionIcon: DSIcon {
        let pool: [DSIcon] = [.temple, .tree, .bridge, .leaf, .sparkles, .cheese, .train, .wind, .baseball, .fish]
        let seed = unicodeScalars.reduce(0) { ($0 &* 31 &+ Int($1.value)) % 100_003 }
        return pool[abs(seed) % pool.count]
    }
}
