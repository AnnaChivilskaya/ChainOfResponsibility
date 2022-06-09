import UIKit

struct Person: Codable {
    let name: String
    let age: Int
    let isDeveloper: Bool
}

struct Result: Codable {
    let result: [Person]
}

struct Date: Codable  {
    let data: [Person]
}

protocol DateHandler {
    var next: DateHandler? { get set }
    func prosessDate(_ data: Data) -> [Person]
}

class LoginDateHandler: DateHandler {
    var next: DateHandler?
    func prosessDate(_ data: Data) -> [Person] {
        var person: [Person] = []
        let decoder  = JSONDecoder()
        do {
            let product = try decoder.decode(Date.self, from: data)
            person = product.data
        }  catch {
            if let next = next {
                person = next.prosessDate(data)
            }
        }
        return person
    }
}

class NetworkDateHandler : DateHandler {
    var next: DateHandler?
    func prosessDate(_ data: Data) -> [Person] {
        var person: [Person] = []
        let decoder  = JSONDecoder()
        do {
            let product = try decoder.decode(Result.self, from: data)
            person = product.result
        }  catch {
            if let next = next {
                person = next.prosessDate(data)
            }
        }
        return person
    }
}

class GeneralDateHandler: DateHandler {
    var next: DateHandler?
    func prosessDate(_ data: Data) -> [Person] {
        var person: [Person] = []
        let decoder  = JSONDecoder()
        do {
            let product = try decoder.decode([Person].self, from: data)
            person = product
        }  catch {
            if let next = next {
                person = next.prosessDate(data)
            }
        }
        return person
    }
}

func data(from file: String) -> [Person] {
    let path1 = Bundle.main.path(forResource: file, ofType: "json")!
    let url = URL(fileURLWithPath: path1)
    let data = try! Data(contentsOf: url)
    var person: [Person] = []
    
    do {
        let loginDateHandler = LoginDateHandler()
        let networkDateHandler = NetworkDateHandler()
        let generalDatehandler = GeneralDateHandler()
        loginDateHandler.next  = networkDateHandler
        networkDateHandler.next = generalDatehandler
        generalDatehandler.next = nil
        person = loginDateHandler.prosessDate(data)
    }
    return person
}

let data1 = data(from: "1")
let data2 = data(from: "2")
let data3 = data(from: "3")
