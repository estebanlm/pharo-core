"
I combine a filesystem and path, which is sufficient to refer to a concrete file or directory. I provide methods for navigating my filesystem, performing filesystem operations and opening and closing files.  I am the primary mechanism for working with files and directories. 

| working |
working := FileSystem disk workingDirectory.
working files 

| disk |
disk := FileSystem disk.
disk root.                               	""a reference to the root directory""
disk working.                         	""a reference to the working directory""
"
Class {
	#name : #FileReference,
	#superclass : #AbstractFileReference,
	#instVars : [
		'filesystem',
		'path'
	],
	#category : #'FileSystem-Core-Public'
}

{ #category : #'cross platform' }
FileReference class >> / aString [
	"Answer a reference to the argument resolved against the root of the current disk filesystem."
	
	^ FileSystem disk / aString
]

{ #category : #'instance creation' }
FileReference class >> fileSystem: aFilesystem path: aPath [
	^ self new setFileSystem: aFilesystem path: aPath
]

{ #category : #'instance creation' }
FileReference class >> newTempFilePrefix: prefix suffix: suffix [
	| tmpDir random fileName |
	
	tmpDir := FileLocator temp asFileReference.
	[ 
		random := UUID new asInteger asString.
		fileName := prefix , random , suffix.
		(tmpDir / fileName) exists ] whileTrue.
	^ tmpDir / fileName
]

{ #category : #'instance creation' }
FileReference class >> primDropRequestFileName: dropIndex [
	"Primitive. Return the file name for some file that was just dropped onto the application.
	Fail if dropIndex is out of range or the primitive is not supported."
	<primitive: 'primitiveDropRequestFileName' module:'DropPlugin'>
	^ self primitiveFail 
]

{ #category : #'drag-and-drop' }
FileReference class >> requestDropReference: anInteger [ 
	
	^ (FilePathEncoder decode: (self primDropRequestFileName: anInteger)) asFileReference 
]

{ #category : #navigating }
FileReference >> , extension [
	^ self withPath: self path, extension
]

{ #category : #comparing }
FileReference >> = other [
	"Two FileReferences are considered equal if they refer to the same file / directory.
	As paths can have multiple relative representations, compare the absolute paths."
	"Perform the path comparison last as conversion to absolute paths is relatively expensive"
	^ self species = other species
		and: [self fileSystem = other fileSystem
			and: [self absolutePath = other absolutePath]]

]

{ #category : #accessing }
FileReference >> absolutePath [
	"Return the absolute of the receiver"
	^ self path isRelative
		ifFalse: [ self path ]
		ifTrue: [ filesystem resolve: self path ]
]

{ #category : #converting }
FileReference >> asAbsolute [
	"Return the receiver as an absolute file reference."
	
	^ self isAbsolute
		ifTrue: [ self ]
		ifFalse: [ filesystem referenceTo: (filesystem resolve: path) ]
]

{ #category : #converting }
FileReference >> asFileReference [
	^ self
]

{ #category : #converting }
FileReference >> asPath [
	"Answer the receivers path"

	^path
]

{ #category : #streams }
FileReference >> binaryReadStream [
	"Answer a buffered binary read stream on the receiver"
	
	^ ZnBufferedReadStream on: (filesystem binaryReadStreamOn: self path)
]

{ #category : #streams }
FileReference >> binaryReadWriteStream [
	"Answer a binary read/write stream on the receiver"

	^ ZnBufferedReadWriteStream on: (filesystem binaryWriteStreamOn: self path)
]

{ #category : #streams }
FileReference >> binaryWriteStream [
	"Answer a buffered binary write stream on the receiver"

	^ ZnBufferedWriteStream on: (filesystem binaryWriteStreamOn: self path)
]

{ #category : #comparing }
FileReference >> containsReference: aReference [
	^  aReference fileSystem = filesystem and: [path contains: aReference path]
]

{ #category : #operations }
FileReference >> copyTo: aFileReference [
	"Copy the receiver and create the argument, a file reference."
	
	"If you want to copy a file from a folder into a given folder, the argument should not be the future parent folder
	but a file reference of the future location.  
	Therefore use 
		(folder1 / 'foo.txt') copyTo: (folder2 / 'bar.txt')"
		
	self isDirectory
		ifTrue: [ aFileReference ensureCreateDirectory ]
		ifFalse: [ filesystem copy: path toReference: aFileReference ]
]

{ #category : #copying }
FileReference >> copyWithPath: newPath [
	^ filesystem referenceTo: newPath
]

{ #category : #accessing }
FileReference >> creationTime [ 
	^ filesystem creationTimeOf: self path
]

{ #category : #operations }
FileReference >> delete [
	"Deletes the referenced file or directory. If the directory is not empty, 
	raises an error. Use #deleteAll to delete with the children."

	(self isDirectory and:[self hasChildren]) 
		ifTrue:[DirectoryIsNotEmpty signalWith: self].
	filesystem delete: path
]

{ #category : #operations }
FileReference >> deleteIfAbsent: aBlock [
	self exists 
		ifTrue: [ self delete ]
		ifFalse: aBlock
]

{ #category : #operations }
FileReference >> ensureCreateDirectory [
	"Create if necessary a directory for the receiver."
	filesystem ensureCreateDirectory: path
	
]

{ #category : #navigating }
FileReference >> entries [
	"Return the entries (meta data - file description) of the direct children of the receiver"
	^ self fileSystem entriesAt: self path 
]

{ #category : #accessing }
FileReference >> entry [
	"Return the entry (meta data) describing the receiver."
	^ filesystem entryAt: path
]

{ #category : #testing }
FileReference >> exists [
	^ filesystem exists: path
]

{ #category : #accessing }
FileReference >> fileSystem [
	"Return the filesystem to which the receiver belong."
	^ filesystem
]

{ #category : #accessing }
FileReference >> fullName [
	"Return the full path name of the receiver."
	^ filesystem stringFromPath: (filesystem resolve: path)
]

{ #category : #accessing }
FileReference >> fullPath [
	^ self path
]

{ #category : #testing }
FileReference >> hasChildren [
	"Return whether the receiver has any children."
	"FileSystem workingDirectory hasChildren"
	
	^ filesystem hasChildren: path
]

{ #category : #testing }
FileReference >> hasDirectories [
	"Return whether the receiver has children that are directories."
	"FileSystem workingDirectory hasDirectories"
	
	^ filesystem hasDirectories: path
]

{ #category : #testing }
FileReference >> hasFiles [
	"Return whether the receiver has children that are files."
	"FileSystem workingDirectory hasFiles"
	
	^ filesystem hasFiles: path
]

{ #category : #comparing }
FileReference >> hash [
	^ path hash bitXor: filesystem hash
]

{ #category : #testing }
FileReference >> isAbsolute [
	^ path isAbsolute
]

{ #category : #testing }
FileReference >> isDirectory [
	^ filesystem isDirectory: path
]

{ #category : #testing }
FileReference >> isFile [
	^ filesystem isFile: path
]

{ #category : #testing }
FileReference >> isReadable [
	^ filesystem isReadable: path
]

{ #category : #testing }
FileReference >> isRelative [
	^ path isRelative
]

{ #category : #testing }
FileReference >> isRoot [
	^ path isRoot
]

{ #category : #testing }
FileReference >> isSymlink [ 
	^ filesystem isSymlink: path
]

{ #category : #testing }
FileReference >> isWritable [
	^ filesystem isWritable: path
]

{ #category : #utilities }
FileReference >> lastFileFor: baseFileName extension: extension [
	"Assumes a file is named using a version number encoded as '.' followed by digits
  preceding the file extension, e.g., games.22.ston
  Answer the file name with the largest number.
  If a version number is not found, raises an error"

	"FileSystem workingDirectory lastFileFor: 'games' extension: 'ston'"

	| files |
	files := self childrenMatching: baseFileName , '.*.' , extension.
	files ifEmpty: [ ^ self error: 'No file with number pattern' ].
	"splitting twice but for now a simple '*.*.*' does not work since it selects: name.45.677.mcz"
	files := files select: [ :each | (each basename splitOn: $.) size = 3].
	^ (files
		asSortedCollection:
			[ :a :b | ((a basename splitOn: $.) at: 2) asNumber < ((b basename splitOn: $.) at: 2) asNumber ])
		last
]

{ #category : #accessing }
FileReference >> mimeTypes [
	"Return the possible mime types for the given path."
	^ filesystem mimeTypesAt: path
]

{ #category : #accessing }
FileReference >> modificationTime [ 
	"Returns the last date of modification of self"
	^ filesystem modificationTimeOf: self path
]

{ #category : #operations }
FileReference >> moveTo: aReference [
	"Move the receiver in the location passed as argument.
	
	(FileSystem disk workingDirectory / 'paf' ) ensureCreateFile.
	(FileSystem disk workingDirectory / 'fooFolder') ensureCreateDirectory. 
	(FileSystem disk workingDirectory / 'paf' ) moveTo: (FileSystem disk workingDirectory / 'fooFolder' / 'paf')
	
	Note that the receiver is modified to point to the new location."
	
	| result |
	result := self fileSystem 
		move: self path
		to: aReference resolve.
	result ifNotNil: [
		self setFileSystem: result fileSystem path: result path ].		
]

{ #category : #utilities }
FileReference >> nextNameFor: baseFileName extension: extension [
  "Assumes a file name includes a version number encoded as '.' followed by digits 
   preceding the file extension, e.g., games.22.ston
   Increment the version number (of the largest one) and answer the new file name, e.g., games23.ston
   If a version number is not found, set the version to 1 and answer a new file name"

	"(FileSystem workingDirectory nextNameFor: 'games' extension: 'ston') asFileReference ensureCreateFile"

	| files splits version |
	files := self childrenMatching: baseFileName , '.*.' , extension.
	files ifEmpty: [ ^ baseFileName , '.1.' , extension ].
	splits := files
		collect: [ :filename | filename basename splitOn: $. ]
		thenSelect: [ :split | (split at: 1) = baseFileName and: [ split size = 3 ] ].
	splits := splits asSortedCollection: [ :a :b | (a at: 2) asNumber < (b at: 2) asNumber ].
	version := splits isEmpty
		ifTrue: [ 1 ]
		ifFalse: [ (splits last at: 2) asNumber + 1 ].
	^ baseFileName , '.' , version asString , '.' , extension
]

{ #category : #utilities }
FileReference >> nextVersion [
	"Assumes a file (or folder) name includes a version number encoded as '.' followed by digits 
	preceding the file extension.  Increment the version number and answer the new file name.
	If a version number is not found, return just the file"

	| parent version versionNumbers nameWithoutExtension |
	
	self exists
		ifFalse: [ ^ self ].
	
	parent := self parent.
	nameWithoutExtension := self basename copyUpTo: $..
	
	versionNumbers := parent children 
				select: [ :f| 
					(f basename beginsWith: nameWithoutExtension) ]
				thenCollect: [ :f| 
					Number squeezeNumberOutOfString: (f basename last: (f basename size - nameWithoutExtension size - 1))   ifFail: [ 0 ]].
	
	versionNumbers ifEmpty: [ ^self ].
	
	version := versionNumbers max + 1.
	^ parent / (nameWithoutExtension , '.', version asString) , self extension
]

{ #category : #streams }
FileReference >> openWritable: aBoolean [ 
	^ filesystem open: path writable: aBoolean
]

{ #category : #accessing }
FileReference >> path [
	"Return the path internal representation that denotes the receiver in the context of its filesystem. "
	^ path
]

{ #category : #printing }
FileReference >> pathString [
	"Return the full path name of the receiver."
	
	^ filesystem stringFromPath: (filesystem resolve: path)
]

{ #category : #accessing }
FileReference >> permissions [
	^ filesystem permissions: self path
]

{ #category : #printing }
FileReference >> printOn: aStream [
	filesystem forReferencePrintOn: aStream.
	filesystem printPath: path on: aStream
]

{ #category : #streams }
FileReference >> readStream [

	^ self readStreamEncoded: 'utf8'
]

{ #category : #operations }
FileReference >> renameTo: newBasename [
	
	| destinationPath |
	destinationPath := self fileSystem 
		rename: self 
		to: self parent / newBasename.
	
	destinationPath ifNotNil: [
		self 
			setFileSystem: filesystem 
			path: destinationPath ].
	^ self
		
]

{ #category : #accessing }
FileReference >> resolve [
	^ self
]

{ #category : #resolving }
FileReference >> resolvePath: anObject [
	^ self withPath: (path resolve: anObject)
]

{ #category : #resolving }
FileReference >> resolveReference: aReference [
	
	^ (filesystem = aReference fileSystem or: [aReference isRelative])
		ifTrue: [filesystem referenceTo: (path resolvePath: aReference path)]
		ifFalse: [aReference]
]

{ #category : #resolving }
FileReference >> resolveString: aString [ 
	| thePath |
	thePath := filesystem pathFromString: aString.
	^ filesystem referenceTo: (path resolve: thePath)
]

{ #category : #'initialize-release' }
FileReference >> setFileSystem: aFilesystem path: aPath [
	filesystem := aFilesystem.
	path := aPath
]

{ #category : #accessing }
FileReference >> size [
	^ filesystem sizeOf: path
]

{ #category : #streams }
FileReference >> writeStream [
	
	^ self writeStreamEncoded: 'utf8'
]
