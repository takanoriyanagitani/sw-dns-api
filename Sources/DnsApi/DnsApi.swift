import class AsyncAlgorithms.AsyncChannel
import struct AsyncDNSResolver.AAAARecord
import struct AsyncDNSResolver.ARecord
import struct AsyncDNSResolver.AsyncDNSResolver
import struct AsyncDNSResolver.MXRecord
import struct AsyncDNSResolver.NSRecord
import struct AsyncDNSResolver.PTRRecord
import struct AsyncDNSResolver.SOARecord
import struct AsyncDNSResolver.SRVRecord
import struct AsyncDNSResolver.TXTRecord
import struct Foundation.Data
import class Foundation.JSONEncoder

public enum DnsApiErr: Error {
  case fatal(String)
}

public func recordsA(name: String, resolver: AsyncDNSResolver) async -> Result<[ARecord], Error> {
  do {
    return .success(try await resolver.queryA(name: name))
  } catch {
    return .failure(error)
  }
}

public func recordsA4(name: String, resolver: AsyncDNSResolver) async -> Result<[AAAARecord], Error>
{
  do {
    return .success(try await resolver.queryAAAA(name: name))
  } catch {
    return .failure(error)
  }
}

public func queryCNAME(name: String, resolver: AsyncDNSResolver) async -> Result<String?, Error> {
  do {
    return .success(try await resolver.queryCNAME(name: name))
  } catch {
    return .failure(error)
  }
}

public func recordsMX(name: String, resolver: AsyncDNSResolver) async -> Result<[MXRecord], Error> {
  do {
    return .success(try await resolver.queryMX(name: name))
  } catch {
    return .failure(error)
  }
}

public func recordNS(name: String, resolver: AsyncDNSResolver) async -> Result<NSRecord, Error> {
  do {
    return .success(try await resolver.queryNS(name: name))
  } catch {
    return .failure(error)
  }
}

public func recordPTR(name: String, resolver: AsyncDNSResolver) async -> Result<PTRRecord, Error> {
  do {
    return .success(try await resolver.queryPTR(name: name))
  } catch {
    return .failure(error)
  }
}

public func recordSOA(name: String, resolver: AsyncDNSResolver) async -> Result<SOARecord?, Error> {
  do {
    return .success(try await resolver.querySOA(name: name))
  } catch {
    return .failure(error)
  }
}

public func recordsSRV(name: String, resolver: AsyncDNSResolver) async -> Result<[SRVRecord], Error>
{
  do {
    return .success(try await resolver.querySRV(name: name))
  } catch {
    return .failure(error)
  }
}

public func recordsTXT(name: String, resolver: AsyncDNSResolver) async -> Result<[TXTRecord], Error>
{
  do {
    return .success(try await resolver.queryTXT(name: name))
  } catch {
    return .failure(error)
  }
}

public struct AnswerA: Codable, Sendable {
  public let address: String
  public let description: String
  public let ttl: Int32?

  public static func fromRaw(_ raw: ARecord) -> Self {
    Self(
      address: raw.address.address, description: raw.description, ttl: raw.ttl,
    )
  }
}

public struct AnswerA4: Codable, Sendable {
  public let address: String
  public let description: String
  public let ttl: Int32?

  public static func fromRaw(_ raw: AAAARecord) -> Self {
    Self(
      address: raw.address.address, description: raw.description, ttl: raw.ttl,
    )
  }
}

public struct AnswerCNAME: Codable, Sendable {
  public let cname: String

  public static func fromRaw(_ raw: String) -> Self {
    Self(cname: raw)
  }
}

public struct AnswerMX: Codable, Sendable {
  public let description: String
  public let host: String
  public let priority: UInt16

  public static func fromRaw(_ raw: MXRecord) -> Self {
    Self(description: raw.description, host: raw.host, priority: raw.priority)
  }
}

public struct AnswerNS: Codable, Sendable {
  public let description: String
  public let servers: [String]

  public static func fromRaw(_ raw: NSRecord) -> Self {
    Self(description: raw.description, servers: raw.nameservers)
  }
}

public struct AnswerPTR: Codable, Sendable {
  public let description: String
  public let names: [String]

  public static func fromRaw(_ raw: PTRRecord) -> Self {
    Self(description: raw.description, names: raw.names)
  }
}

public struct AnswerSOA: Codable, Sendable {
  public let description: String
  public let expire: UInt32
  public let mname: String?
  public let refresh: UInt32
  public let retry: UInt32
  public let rname: String?
  public let serial: UInt32
  public let ttl: UInt32

  public static func fromRaw(_ raw: SOARecord) -> Self {
    Self(
      description: raw.description,
      expire: raw.expire,
      mname: raw.mname,
      refresh: raw.refresh,
      retry: raw.retry,
      rname: raw.rname,
      serial: raw.serial,
      ttl: raw.ttl,
    )
  }
}

public struct AnswerSRV: Codable, Sendable {
  public let description: String
  public let host: String
  public let port: UInt16
  public let priority: UInt16
  public let weight: UInt16

  public static func fromRaw(_ raw: SRVRecord) -> Self {
    Self(
      description: raw.description,
      host: raw.host,
      port: raw.port,
      priority: raw.priority,
      weight: raw.weight,
    )
  }
}

public struct AnswerTXT: Codable, Sendable {
  public let description: String
  public let txt: String

  public static func fromRaw(_ raw: TXTRecord) -> Self {
    Self(
      description: raw.description,
      txt: raw.txt,
    )
  }
}

public func answerCNAME(
  name: String,
  resolver: AsyncDNSResolver,
) async -> Result<AnswerCNAME?, Error> {
  let cname: Result<String?, _> = await queryCNAME(
    name: name,
    resolver: resolver,
  )
  switch cname {
  case .success(.some(let cn)): return .success(.fromRaw(cn))
  case .success(.none): return .success(nil)
  case .failure(let err): return .failure(err)
  }
}

public func answerNS(
  name: String,
  resolver: AsyncDNSResolver,
) async -> Result<AnswerNS, Error> {
  let record: Result<NSRecord, _> = await recordNS(
    name: name,
    resolver: resolver,
  )
  return record.map {
    let raw: NSRecord = $0
    return .fromRaw(raw)
  }
}

public func answerPTR(
  name: String,
  resolver: AsyncDNSResolver,
) async -> Result<AnswerPTR, Error> {
  let record: Result<PTRRecord, _> = await recordPTR(
    name: name,
    resolver: resolver,
  )
  return record.map { .fromRaw($0) }
}

public func answerSOA(
  name: String,
  resolver: AsyncDNSResolver,
) async -> Result<AnswerSOA?, Error> {
  let record: Result<SOARecord?, _> = await recordSOA(
    name: name,
    resolver: resolver,
  )
  switch record {
  case .success(.some(let raw)): return .success(.some(.fromRaw(raw)))
  case .success(.none): return .success(nil)
  case .failure(let err): return .failure(err)
  }
}

public func answerA(
  name: String,
  resolver: AsyncDNSResolver,
) async -> Result<[AnswerA], Error> {
  let records: Result<[ARecord], _> = await recordsA(
    name: name,
    resolver: resolver,
  )
  return records.map {
    let raws: [ARecord] = $0
    return raws.map {
      let raw: ARecord = $0
      return .fromRaw(raw)
    }
  }
}

public func answerA4(
  name: String,
  resolver: AsyncDNSResolver,
) async -> Result<[AnswerA4], Error> {
  let records: Result<[AAAARecord], _> = await recordsA4(
    name: name,
    resolver: resolver,
  )
  return records.map {
    let raws: [AAAARecord] = $0
    return raws.map { .fromRaw($0) }
  }
}

public func answerMX(
  name: String,
  resolver: AsyncDNSResolver,
) async -> Result<[AnswerMX], Error> {
  let records: Result<[MXRecord], _> = await recordsMX(
    name: name,
    resolver: resolver,
  )
  return records.map {
    let raws: [MXRecord] = $0
    return raws.map { .fromRaw($0) }
  }
}

public func answerSRV(
  name: String,
  resolver: AsyncDNSResolver,
) async -> Result<[AnswerSRV], Error> {
  let records: Result<[SRVRecord], _> = await recordsSRV(
    name: name,
    resolver: resolver,
  )
  return records.map {
    let raws: [SRVRecord] = $0
    return raws.map { .fromRaw($0) }
  }
}

public func answerTXT(
  name: String,
  resolver: AsyncDNSResolver,
) async -> Result<[AnswerTXT], Error> {
  let records: Result<[TXTRecord], _> = await recordsTXT(
    name: name,
    resolver: resolver,
  )
  return records.map {
    let raws: [TXTRecord] = $0
    return raws.map { .fromRaw($0) }
  }
}

public enum QueryType: Sendable {
  case unspecified
  case raw(String)

  case a
  case aaaa
  case cname
  case mx
  case ns
  case ptr
  case soa
  case srv
  case txt

  public static func fromRaw(_ raw: String) -> Self {
    switch raw {
    case "a": return Self.a
    case "aaaa": return Self.aaaa
    case "cname": return Self.cname
    case "mx": return Self.mx
    case "ns": return Self.ns
    case "ptr": return Self.ptr
    case "soa": return Self.soa
    case "srv": return Self.srv
    case "txt": return Self.txt
    default: return Self.raw(raw)
    }
  }

  public static func toAnswer(
    typ: Self,
    name: String,
    resolver: AsyncDNSResolver,
  ) async -> Result<Answer, Error> {
    switch typ {
    case .a: return await answerA(name: name, resolver: resolver).map { .a($0) }
    case .aaaa: return await answerA4(name: name, resolver: resolver).map { .aaaa($0) }
    case .cname: return await answerCNAME(name: name, resolver: resolver).map { .cname($0) }
    case .mx: return await answerMX(name: name, resolver: resolver).map { .mx($0) }
    case .ns: return await answerNS(name: name, resolver: resolver).map { .ns($0) }
    case .ptr: return await answerPTR(name: name, resolver: resolver).map { .ptr($0) }
    case .soa: return await answerSOA(name: name, resolver: resolver).map { .soa($0) }
    case .srv: return await answerSRV(name: name, resolver: resolver).map { .srv($0) }
    case .txt: return await answerTXT(name: name, resolver: resolver).map { .txt($0) }
    default: return await answerA(name: name, resolver: resolver).map { .a($0) }
    }
  }

}

public enum Answer: Sendable, Codable {
  case a([AnswerA])
  case aaaa([AnswerA4])
  case cname(AnswerCNAME?)
  case mx([AnswerMX])
  case ns(AnswerNS)
  case ptr(AnswerPTR)
  case soa(AnswerSOA?)
  case srv([AnswerSRV])
  case txt([AnswerTXT])
}

public struct Request: Sendable {
  public let name: String
  public let typ: QueryType
  public let reply: AsyncChannel<Result<Answer, Error>>

  public static func newRequest(
    name: String,
    typ: QueryType,
  ) -> Self {
    Self(name: name, typ: typ, reply: AsyncChannel())
  }
}

public func startHandler(reqs: AsyncChannel<Request>) async {
  let rdns: Result<AsyncDNSResolver, _> = Result(
    catching: { try AsyncDNSResolver() },
  )
  let odns: AsyncDNSResolver? = try? rdns.get()

  guard let dns = odns else {
    for await req in reqs {
      let reply: AsyncChannel<Result<_, Error>> = req.reply
      await reply.send(.failure(DnsApiErr.fatal("no dns resolver")))
      reply.finish()
    }
    return
  }

  for await req in reqs {
    let name: String = req.name
    let typ: QueryType = req.typ

    let reply: AsyncChannel<Result<Answer, _>> = req.reply
    let rans: Result<Answer, _> = await QueryType.toAnswer(
      typ: typ,
      name: name,
      resolver: dns,
    )
    await reply.send(rans)
    reply.finish()
  }
}
