//
//  TicketPersistenceManager.swift
//  RateMovie
//
//  Created by DHIKA ADITYA ARE on 03/09/26.
//

import Foundation
import CoreData
import UIKit

public protocol TicketPersistenceManagerProtocol {
    func saveTicket(_ ticket: TicketModel, completion: @escaping (Result<TicketModel, Error>) -> Void)
    func fetchTicket(by ticketId: String, completion: @escaping (Result<TicketModel?, Error>) -> Void)
    func fetchAllTickets(completion: @escaping (Result<[TicketModel], Error>) -> Void)
    func fetchTickets(by movieId: Int, completion: @escaping (Result<[TicketModel], Error>) -> Void)
    func deleteTicket(by ticketId: String, completion: @escaping (Result<Bool, Error>) -> Void)
}

public final class TicketPersistenceManager: TicketPersistenceManagerProtocol {
    public static let shared = TicketPersistenceManager()
    
    private let persistentContainer: NSPersistentContainer
    
    public init(container: NSPersistentContainer? = nil) {
        if let container = container {
            self.persistentContainer = container
        } else if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            self.persistentContainer = appDelegate.persistentContainer
        } else {
            let container = NSPersistentContainer(name: "RateMovie")
            container.loadPersistentStores { _, error in
                if let error = error {
                    print("Unresolved CoreData error: \(error)")
                }
            }
            container.viewContext.automaticallyMergesChangesFromParent = true
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            self.persistentContainer = container
        }
    }
    
    private func newBackgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        context.undoManager = nil
        return context
    }
    
    public func saveTicket(_ ticket: TicketModel, completion: @escaping (Result<TicketModel, Error>) -> Void) {
        let context = newBackgroundContext()
        context.perform {
            guard let entityDescription = NSEntityDescription.entity(forEntityName: "TicketEntity", in: context) else {
                completion(.failure(NSError(domain: "TicketPersistenceManager", code: 404, userInfo: [NSLocalizedDescriptionKey: "TicketEntity description not found"])))
                return
            }
            
            let ticketObject = NSManagedObject(entity: entityDescription, insertInto: context)
            ticketObject.setValue(ticket.ticketId ?? UUID().uuidString, forKey: "ticketId")
            ticketObject.setValue(ticket.movieId ?? 0, forKey: "movieId")
            ticketObject.setValue(ticket.movieTitle, forKey: "movieTitle")
            ticketObject.setValue(ticket.showtime, forKey: "showtime")
            ticketObject.setValue(ticket.seats, forKey: "seats")
            ticketObject.setValue(ticket.qrCodeString, forKey: "qrCodeString")
            
            do {
                try context.save()
                let savedModel = TicketModel(
                    ticketId: ticketObject.value(forKey: "ticketId") as? String,
                    movieId: ticketObject.value(forKey: "movieId") as? Int,
                    movieTitle: ticketObject.value(forKey: "movieTitle") as? String,
                    showtime: ticketObject.value(forKey: "showtime") as? String,
                    seats: ticketObject.value(forKey: "seats") as? String,
                    qrCodeString: ticketObject.value(forKey: "qrCodeString") as? String
                )
                DispatchQueue.main.async {
                    completion(.success(savedModel))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    public func fetchTicket(by ticketId: String, completion: @escaping (Result<TicketModel?, Error>) -> Void) {
        let context = newBackgroundContext()
        context.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: "TicketEntity")
            request.predicate = NSPredicate(format: "ticketId == %@", ticketId)
            request.fetchLimit = 1
            
            do {
                let results = try context.fetch(request)
                if let first = results.first {
                    let model = TicketModel(
                        ticketId: first.value(forKey: "ticketId") as? String,
                        movieId: first.value(forKey: "movieId") as? Int,
                        movieTitle: first.value(forKey: "movieTitle") as? String,
                        showtime: first.value(forKey: "showtime") as? String,
                        seats: first.value(forKey: "seats") as? String,
                        qrCodeString: first.value(forKey: "qrCodeString") as? String
                    )
                    DispatchQueue.main.async {
                        completion(.success(model))
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(.success(nil))
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    public func fetchAllTickets(completion: @escaping (Result<[TicketModel], Error>) -> Void) {
        let context = newBackgroundContext()
        context.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: "TicketEntity")
            do {
                let results = try context.fetch(request)
                let tickets: [TicketModel] = results.map { object in
                    TicketModel(
                        ticketId: object.value(forKey: "ticketId") as? String,
                        movieId: object.value(forKey: "movieId") as? Int,
                        movieTitle: object.value(forKey: "movieTitle") as? String,
                        showtime: object.value(forKey: "showtime") as? String,
                        seats: object.value(forKey: "seats") as? String,
                        qrCodeString: object.value(forKey: "qrCodeString") as? String
                    )
                }
                DispatchQueue.main.async {
                    completion(.success(tickets))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    public func fetchTickets(by movieId: Int, completion: @escaping (Result<[TicketModel], Error>) -> Void) {
        let context = newBackgroundContext()
        context.perform {
            let request = NSFetchRequest<NSManagedObject>(entityName: "TicketEntity")
            request.predicate = NSPredicate(format: "movieId == %d", movieId)
            do {
                let results = try context.fetch(request)
                let tickets: [TicketModel] = results.map { object in
                    TicketModel(
                        ticketId: object.value(forKey: "ticketId") as? String,
                        movieId: object.value(forKey: "movieId") as? Int,
                        movieTitle: object.value(forKey: "movieTitle") as? String,
                        showtime: object.value(forKey: "showtime") as? String,
                        seats: object.value(forKey: "seats") as? String,
                        qrCodeString: object.value(forKey: "qrCodeString") as? String
                    )
                }
                DispatchQueue.main.async {
                    completion(.success(tickets))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
    
    public func deleteTicket(by ticketId: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let context = newBackgroundContext()
        context.perform {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "TicketEntity")
            request.predicate = NSPredicate(format: "ticketId == %@", ticketId)
            let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)
            
            do {
                try context.execute(deleteRequest)
                try context.save()
                DispatchQueue.main.async {
                    completion(.success(true))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
