//
//  NSModelActor.swift
//
//
//  Created by Yang Xu on 2024/4/9.
//

import _Concurrency
import CoreData
import Foundation

@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public final class NSModelObjectContextExecutor: @unchecked Sendable, SerialExecutor {
  public final let context: NSManagedObjectContext
  public init(context: NSManagedObjectContext) {
    self.context = context
  }
  
    public func enqueue(_ job: UnownedJob) {
        let unownedExecutor = asUnownedSerialExecutor()
        context.performAndWait {
            job.runSynchronously(on: unownedExecutor)
        }
    }

  public func asUnownedSerialExecutor() -> UnownedSerialExecutor {
    UnownedSerialExecutor(ordinary: self)
  }
}

@available(macOS 14.0, iOS 17.0, watchOS 10.0, tvOS 17.0, visionOS 1.0, *)
public final class NSModelObjectContextExecutorJob: @unchecked Sendable, SerialExecutor {
  public final let context: NSManagedObjectContext
  public init(context: NSManagedObjectContext) {
    self.context = context
  }

  public func enqueue(_ job: consuming ExecutorJob) {
    let unownedJob = UnownedJob(job)
    let unownedExecutor = asUnownedSerialExecutor()
    context.perform {
      unownedJob.runSynchronously(on: unownedExecutor)
    }
  }

  public func asUnownedSerialExecutor() -> UnownedSerialExecutor {
    UnownedSerialExecutor(ordinary: self)
  }
}

public protocol NSModelActor: Actor {
  /// The NSPersistentContainer for the NSModelActor
  nonisolated var modelContainer: NSPersistentContainer { get }

  /// The executor that coordinates access to the model actor.
  nonisolated var modelExecutor: NSModelObjectContextExecutor { get }
}

extension NSModelActor {
  /// The optimized, unonwned reference to the model actor's executor.
  public nonisolated var unownedExecutor: UnownedSerialExecutor {
    modelExecutor.asUnownedSerialExecutor()
  }

  /// The context that serializes any code running on the model actor.
  public var modelContext: NSManagedObjectContext {
    modelExecutor.context
  }

  /// Returns the model for the specified identifier, downcast to the appropriate class.
  public subscript<T>(id: NSManagedObjectID, as _: T.Type) -> T? where T: NSManagedObject {
    try? modelContext.existingObject(with: id) as? T
  }
}
