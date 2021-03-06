import Foundation
import Fluent

public enum FluentQueryPredicateOperator: String {
    case equal = "="
    case notEqual = "!="
    case lessThan = "<"
    case greaterThan = ">"
    case lessThanOrEqual = "<="
    case greaterThanOrEqual = ">="
    case `in` = "IN"
    case notIn = "NOT IN"
    case between = "BETWEEN"
    case like = "LIKE"
    case ilike = "ILIKE"
    case notLike = "NOT LIKE"
    case notILike = "NOT ILIKE"
    case isNull = "IS NULL"
    case isNotNull = "IS NOT NULL"
}

public class FluentQuery: FQPart, CustomStringConvertible {
    public var select: FQSelect = FQSelect()
    public var froms: [FQPart] = []
    public var joins: [FQJoinGenericType] = []
    public var `where`: FQWhere?
    public var groupBy: FQGroupBy?
    public var having: FQWhere?
    public var orderBy: FQOrderBy?
    public var offset: Int?
    public var limit: Int?
    
    public init(copy from: FluentQuery? = nil) {
        if let from = from {
            select = FQSelect(copy: from.select)
            froms = from.froms.map { $0 }
            joins = from.joins.map { $0 }
            if let `where` = from.where {
                self.where = FQWhere(copy: `where`)
            }
            if let groupBy = groupBy {
                self.groupBy = FQGroupBy(copy: groupBy)
            }
            if let having = from.having {
                self.having = FQWhere(copy: having)
            }
            if let orderBy = from.orderBy {
                self.orderBy = FQOrderBy(copy: orderBy)
            }
            offset = from.offset
            limit = from.limit
        }
    }
    
    @discardableResult
    public func select(_ select: FQSelect) -> Self {
        self.select.joinAnotherInstance(select)
        return self
    }
    
    @discardableResult
    public func select(_ str: String) -> Self {
        select.field(str)
        return self
    }
    
    @discardableResult
    public func select<T>(all: T.Type) -> Self where T: Model {
        select.all(all)
        return self
    }
    
    @discardableResult
    public func select<T>(_ kp: T, as: String? = nil) -> Self where T: FQUniversalKeyPath {
        select.field(kp)
        return self
    }
    
    @discardableResult
    public func select<T>(distinct kp: T, as: String? = nil) -> Self where T: FQUniversalKeyPath {
        select.distinct(kp, as: `as`)
        return self
    }
    
    @discardableResult
    public func select(_ json: FQJSON, as: String) -> Self {
        select.field(as: `as`, json)
        return self
    }
    
    @discardableResult
    public func select<M>(_ func: FQAggregate.FunctionWithKeyPath<M>, as: String) -> Self where M: FQUniversalKeyPath {
        select.func(`func`,  as: `as`)
        return self
    }
    
    @discardableResult
    public func select<M>(_ func: FQJSON.FunctionWithModelAlias<M>, as: String) -> Self where M: Model {
        select.func(`func`, as: `as`)
        return self
    }
    
    @discardableResult
    public func select<M>(_ func: FQJSON.FunctionWithModel<M>, as: String) -> Self where M: Model {
        select.func(`func`, as: `as`)
        return self
    }
    
    @discardableResult
    public func select<M, V>(_ func: FQJSON.FuncOptionKP<M, V>, as: String) -> Self where M: Model {
        select.func(`func`, as: `as`)
        return self
    }
    
    @discardableResult
    public func select<M, V>(_ func: FQJSON.FuncOptionAKP<M, V>, as: String) -> Self where M: Model {
        select.func(`func`, as: `as`)
        return self
    }
    
    @discardableResult
    public func from(_ db: String, as asKey: String) -> Self {
        froms.append("\(db.doubleQuotted) as \(asKey.doubleQuotted)")
        return self
    }
    
    @discardableResult
    public func from(_ db: String) -> Self {
        froms.append("\(db.doubleQuotted)")
        return self
    }
    
    @discardableResult
    public func from<T>(_ db: T.Type) -> Self where T: Model {
        froms.append(T.FQType.query)
        return self
    }
    
    @discardableResult
    public func from<T>(_ db: FQAlias<T>) -> Self {
        froms.append(db.query)
        return self
    }
    
    @discardableResult
    public func from(raw: String) -> Self {
        froms.append(raw)
        return self
    }
    
    @discardableResult
    public func join<T>(_ mode: FQJoinMode, _ table: T.Type, where: FQWhere) -> Self where T: Model {
        joins.append(FQJoin(mode, table: T.FQType.self, where: `where`))
        return self
    }
    
    @discardableResult
    public func join<T>(_ mode: FQJoinMode, _ table: FQAlias<T>, where: FQWhere) -> Self where T: Model {
        joins.append(FQJoin(mode, table: table, where: `where`))
        return self
    }
    
    @discardableResult
    public func `where`(_ where: FQWhere) -> Self {
        if let w = self.`where` {
            w.joinAnotherInstance(`where`, by: "AND")
        } else {
            self.`where` = `where`
        }
        return self
    }
    
    @discardableResult
    public func having(_ where: FQWhere) -> Self {
        if let w = self.having {
            w.joinAnotherInstance(`where`, by: "AND")
        } else {
            self.having = `where`
        }
        return self
    }
    
    @discardableResult
    public func groupBy(_ groupBy: FQGroupBy) -> Self {
        if let w = self.groupBy {
            w.joinAnotherInstance(groupBy)
        } else {
            self.groupBy = groupBy
        }
        return self
    }
    
    @discardableResult
    public func orderBy(_ orderBy: FQOrderBy) -> Self {
        if let w = self.orderBy {
            w.joinAnotherInstance(orderBy)
        } else {
            self.orderBy = orderBy
        }
        return self
    }
    
    @discardableResult
    public func offset(_ v: Int) -> Self {
        self.offset = v
        return self
    }
    
    @discardableResult
    public func limit(_ v: Int) -> Self {
        self.limit = v
        return self
    }
    
    public var query: String {
        var result = "SELECT"
        result.append(FluentQueryNextLine)
        result.append(select.query)
        if froms.count > 0 {
            result.append(FluentQueryNextLine)
            result.append("FROM")
            for (index, from) in froms.enumerated() {
                if index > 0 {
                    result.append(",")
                }
                result.append(FluentQueryNextLine)
                result.append(from.query)
            }
        }
        for join in joins {
            result.append(FluentQueryNextLine)
            result.append(join.query)
        }
        if let w = `where` {
            result.append(FluentQueryNextLine)
            result.append("WHERE")
            result.append(FluentQueryNextLine)
            result.append(w.query)
        }
        if let groupBy = groupBy {
            result.append(FluentQueryNextLine)
            result.append("GROUP BY")
            result.append(FluentQueryNextLine)
            result.append(groupBy.query)
        }
        if let having = having {
            result.append(FluentQueryNextLine)
            result.append("HAVING")
            result.append(FluentQueryNextLine)
            result.append(having.query)
        }
        if let orderBy = orderBy {
            result.append(FluentQueryNextLine)
            result.append("ORDER BY")
            result.append(FluentQueryNextLine)
            result.append(orderBy.query)
        }
        if let offset = offset {
            result.append(FluentQueryNextLine)
            result.append("OFFSET \(offset)")
        }
        if let limit = limit {
            result.append(FluentQueryNextLine)
            result.append("LIMIT \(limit)")
        }
        return result
    }
    
    public func build() -> String {
        return query
    }
    
    public var description: String {
        return query
    }
}

extension FluentQuery {
    static func formattedPath<T, V>(_ table: FQTable<T>.Type, _ kp: KeyPath<T, V>) -> String where T: Model {
        return FluentQuery.formattedPath(table.alias, kp)
    }
    
    static func formattedPath<T, V>(_ table: String, _ kp: KeyPath<T, V>) -> String where T: Model {
        var formattedPath = ""
        let values: [String] = T.describeKeyPath(kp)
        for (index, p) in values.enumerated() {
            if index == 0 {
                formattedPath.append("\(p.doubleQuotted)")
            } else {
                formattedPath.append("->")
                formattedPath.append("\(p.singleQuotted)")
            }
        }
        return "\(table.doubleQuotted).\(formattedPath)"
    }
}

extension Model {
    typealias FQType = FQTable<Self>
    
    static func describeKeyPath<V>(_ kp: KeyPath<Self, V>) -> [String] {
        if let pathParts = try? Self.reflectProperty(forKey: kp)?.path {
            return pathParts ?? []
        }
        return []
    }
    
    static func property<T, V>(_ kp: KeyPath<T, V>) -> String where T: Model {
        return FluentQuery.formattedPath(T.FQType.self, kp)
    }
}

let FluentQueryNextLine = """


"""

public func FQGetKeyPath<T, V>(_ kp: KeyPath<T, V>) -> String where T: Model {
    return FluentQuery.formattedPath(T.FQType.self, kp)
}

public func FQGetKeyPath<T, V>(_ alias: AliasedKeyPath<T, V>) -> String where T: Model {
    return alias.query
}
