import AsyncDNSResolver

import class AsyncAlgorithms.AsyncChannel
import enum DnsApi.Answer
import enum DnsApi.QueryType
import struct DnsApi.Request
import func DnsApi.startHandler
import struct Foundation.Data
import class Foundation.JSONEncoder
import class Foundation.ProcessInfo

@main
struct simpledns {
  static func main() async {
    let env: [String: String] = ProcessInfo.processInfo.environment

    let oname: String? = env["ENV_TARGET_NAME"]
    guard let name = oname else {
      print("no name specified(ENV_TARGET_NAME)")
      return
    }

    let ostyp: String? = env["ENV_TYPE"]
    let otyp: QueryType? = ostyp.map {
      let styp: String = $0
      return .fromRaw(styp)
    }
    let typ: QueryType = otyp ?? .a

    let enc: JSONEncoder = JSONEncoder()

    let req: Request = .newRequest(
      name: name,
      typ: typ,
    )

    let reqs: AsyncChannel<Request> = AsyncChannel()
    Task.detached { await startHandler(reqs: reqs) }
    await reqs.send(req)
    reqs.finish()

    for await rslt in req.reply {
      let oans: Answer? = try? rslt.get()
      guard let ans = oans else {
        print("unable to get the answer. type=\( typ ), name=\( name )")
        return
      }

      let rdat: Result<Data, _> = Result(catching: { try enc.encode(ans) })
      let odat: Data? = try? rdat.get()
      guard let dat = odat else {
        print("unable to serialize the answer")
        return
      }

      let ostr: String? = String(data: dat, encoding: .utf8)
      guard let jstr = ostr else {
        print("invalid json got")
        return
      }

      print(jstr)
      return
    }
  }
}
