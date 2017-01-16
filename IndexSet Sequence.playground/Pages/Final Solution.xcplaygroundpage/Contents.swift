extension CountableClosedRange {
    func merge(_ other: CountableClosedRange) -> CountableClosedRange {
        return Swift.min(lowerBound, other.lowerBound)...Swift.max(upperBound, other.upperBound)
    }
    
    func overlapsOrAdjacent(_ other: CountableClosedRange) -> Bool {
        return (self.lowerBound.advanced(by: -1)...self.upperBound.advanced(by: 1)).overlaps(other)
    }
}

extension Sequence {
    func reduce<A>(_ initial: A, combine: (inout A, Iterator.Element) -> ()) -> A {
        var result = initial
        for element in self {
            combine(&result, element)
        }
        return result
    }
}

struct IndexSet {
    typealias RangeType = CountableClosedRange<Int>
    // Invariant: ranges are sorted
    fileprivate var ranges: [RangeType] = []
    
    mutating func insert(_ range: RangeType) {
        ranges.append(range)
        ranges.sort { $0.lowerBound < $1.lowerBound }
        merge()
    }
    
    private mutating func merge() {
        ranges = ranges.reduce([]) { (result: inout [RangeType], range) in
            if let last = result.last, last.overlapsOrAdjacent(range) {
                result[result.endIndex-1] = last.merge(range)
            } else {
                result.append(range)
            }
        }
    }
}

extension IndexSet {
    struct RangeView: Sequence {
        let base: IndexSet
        
        func makeIterator() -> AnyIterator<RangeType> {
            return AnyIterator(base.ranges.makeIterator())
        }
    }
    
    var rangeView: RangeView {
        return RangeView(base: self)
    }
}

extension IndexSet: Sequence {
    func makeIterator() -> AnyIterator<Int> {
        return AnyIterator(rangeView.joined().makeIterator())
    }
}

var set = IndexSet()
set.insert(4...5)
set.insert(0...2)

for range in set.rangeView {
    print(range)
}

for idx in set {
    print(idx)
}
