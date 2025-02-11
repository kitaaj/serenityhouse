// Cloud Storage Exceptions
class CloudStorageException implements Exception {
  
  const CloudStorageException();
}

class CouldNotCreateEntryException extends CloudStorageException {}
class CouldNotGetEntriesException extends CloudStorageException {}
class CouldNotUpdateEntryException extends CloudStorageException {}
class CouldNotDeleteEntryException extends CloudStorageException {}