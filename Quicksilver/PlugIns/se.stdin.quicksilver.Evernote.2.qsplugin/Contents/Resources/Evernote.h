/*
 * Evernote.h
 */

#import <AppKit/AppKit.h>
#import <ScriptingBridge/ScriptingBridge.h>


@class EvernoteApplication, EvernoteWindow, EvernoteAccountInfo, EvernoteApplication, EvernoteCollectionWindow, EvernoteNoteWindow, EvernoteNotebook, EvernoteTag, EvernoteNote, EvernoteAttachment;

enum EvernotePrintingErrorHandling {
	EvernotePrintingErrorHandlingStandard = 'lwst' /* Standard PostScript error handling */,
	EvernotePrintingErrorHandlingDetailed = 'lwdt' /* print a detailed report of PostScript errors */
};
typedef enum EvernotePrintingErrorHandling EvernotePrintingErrorHandling;

enum EvernoteNotebookTypes {
	EvernoteNotebookTypesSynchronized = 'priv' /* Default notebook type.  Notes are synchronized to and from the server. */,
	EvernoteNotebookTypesPublished = 'publ' /* Synchronized notebook that is publicly available. */,
	EvernoteNotebookTypesLocalOnly = 'loco' /* Local only notebook.  Never synchronized with server.  Only available on this client. */,
	EvernoteNotebookTypesBusiness = 'busi' /* Synchronized business notebook that is publicly available. */
};
typedef enum EvernoteNotebookTypes EvernoteNotebookTypes;

enum EvernoteExportFormats {
	EvernoteExportFormatsENEX = 'enex' /* An XML-based format that preserves the exact note content and all attachments.  Suitable for importing into another Evernote client or 3rd party application.  Use this format for making local backups. */,
	EvernoteExportFormatsHTML = 'exht' /* Content of each note is converted to HTML.  Attachments are exported as separate files that are linked from the note HTML. */
};
typedef enum EvernoteExportFormats EvernoteExportFormats;

enum EvernoteAccountTypes {
	EvernoteAccountTypesStandard = 'EV05' /* Standard (free) account type. */,
	EvernoteAccountTypesPremium = 'EV06' /* Premium account type. */,
	EvernoteAccountTypesOther = 'EV07' /* Specialized account type. */
};
typedef enum EvernoteAccountTypes EvernoteAccountTypes;



/*
 * Standard Suite
 */

// The application's top-level scripting object.
@interface EvernoteApplication : SBApplication
+ (EvernoteApplication *) application;

- (SBElementArray *) windows;

@property (copy, readonly) NSString *name;  // The name of the application.
@property (readonly) BOOL frontmost;  // Is this the active application?
@property (copy, readonly) NSString *version;  // The version number of the application.

- (void) print:(id)x withProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) quit;  // Quit the application.
- (void) delete:(id)x;  // Delete an object.
- (BOOL) exists:(id)x;  // Verify that an object exists.
- (void) synchronize;  // Synchronize with the Evernote server.  Returns immediately.  Does nothing if a sync is currently in progress.
- (EvernoteCollectionWindow *) openCollectionWindowWithQueryString:(NSString *)withQueryString;  // Open a new note collection window.
- (EvernoteNoteWindow *) openNoteWindowWith:(EvernoteNote *)with;  // Open a note window for a specific note.  If the note already is open in a note window, that window is activated and returned, otherwise a new note window is created.
- (NSArray *) findNotes:(NSString *)x;  // Search for notes using the Evernote query syntax.
- (EvernoteNote *) findNote:(NSString *)x;  // Find a single note.
- (EvernoteNotebook *) createNotebook:(NSString *)x withType:(EvernoteNotebookTypes)withType;  // Create a new notebook.
- (void) export:(NSArray *)x to:(NSURL *)to tags:(BOOL)tags format:(EvernoteExportFormats)format;  // Export notes.
- (id) import:(NSURL *)x to:(id)to tags:(BOOL)tags;  // Import notes from an xml file.
- (EvernoteNote *) createNoteFromFile:(NSURL *)fromFile fromUrl:(NSString *)fromUrl withText:(NSString *)withText withHtml:(NSString *)withHtml withEnml:(NSString *)withEnml title:(NSString *)title notebook:(id)notebook tags:(id)tags attachments:(NSArray *)attachments created:(NSDate *)created;  // Create a new note.  You must specify exactly one of 'from file', 'from url', 'with text', or 'with html'.
- (void) assign:(id)x to:(id)to;  // Assign one or more tags to one or more notes.
- (void) unassign:(id)x from:(id)from;  // Un-assign one or more tags from one or more notes.

@end

// A window.
@interface EvernoteWindow : SBObject

@property (copy, readonly) NSString *name;  // The title of the window.
- (NSInteger) id;  // The unique identifier of the window.
@property NSInteger index;  // The index of the window, ordered front to back.
@property NSRect bounds;  // The bounding rectangle of the window.
@property (readonly) BOOL closeable;  // Does the window have a close button?
@property (readonly) BOOL miniaturizable;  // Does the window have a minimize button?
@property BOOL miniaturized;  // Is the window minimized right now?
@property (readonly) BOOL resizable;  // Can the window be resized?
@property BOOL visible;  // Is the window visible right now?
@property (readonly) BOOL zoomable;  // Does the window have a zoom button?
@property BOOL zoomed;  // Is the window zoomed right now?

- (void) close;  // Close a window.
- (void) printWithProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) delete;  // Delete an object.
- (void) moveTo:(SBObject *)to;  // Move an object to a new location.

@end



/*
 * Evernote Suite
 */

// Information about an Evernote account.
@interface EvernoteAccountInfo : SBObject

@property (copy, readonly) NSString *name;  // The account's username.
@property (readonly) EvernoteAccountTypes accountType;  // The account type.
@property (readonly) NSInteger uploadLimit;  // Maximum data upload (in bytes) for the current month.
@property (copy, readonly) NSDate *uploadResetDate;  // When the data upload counter will be reset.
@property (readonly) NSInteger uploadUsed;  // Data uploaded (in bytes) so far for the current month.

- (void) close;  // Close a window.
- (void) printWithProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) delete;  // Delete an object.
- (void) moveTo:(SBObject *)to;  // Move an object to a new location.

@end

// The application's top-level scripting object.
@interface EvernoteApplication (EvernoteSuite)

- (SBElementArray *) notebooks;
- (SBElementArray *) tags;
- (SBElementArray *) windows;
- (SBElementArray *) accounts;

@property BOOL isSynchronizing;  // Is application currently synchronizing?
@property (copy, readonly) EvernoteAccountInfo *currentAccount;  // Information about the currently-active Evernote account.
@property (copy, readonly) NSArray *selection;  // The note(s) selected in the front-most window.  Returns empty list if the front-most window is not a collection or note window, or if there is no front-most window.

@end

// A note collection window.
@interface EvernoteCollectionWindow : EvernoteWindow

- (SBElementArray *) notes;

@property (copy, readonly) NSArray *selectedNotes;  // Notes that are selected in the window.
@property (copy) NSString *queryString;  // The query string used to determine which notes are displayed in the window.  Setting this property causes the window's contents to update to reflect the new query.


@end

// A single-note window.
@interface EvernoteNoteWindow : EvernoteWindow

- (SBElementArray *) notes;

@property (copy, readonly) NSArray *selection;  // The window's single note.


@end

// A notebook.
@interface EvernoteNotebook : SBObject

- (SBElementArray *) notes;

@property (copy) NSString *name;  // The notebook's name.
@property (readonly) EvernoteNotebookTypes notebookType;  // The notebook's type.
- (BOOL) default;  // Indicates if this is the 'default' notebook for the account.

- (void) close;  // Close a window.
- (void) printWithProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) delete;  // Delete an object.
- (void) moveTo:(SBObject *)to;  // Move an object to a new location.

@end

// A tag.
@interface EvernoteTag : SBObject

@property (copy) NSString *name;  // The tag's name.
@property (copy) id parent;  // The tag's parent tag, if any.

- (void) close;  // Close a window.
- (void) printWithProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) delete;  // Delete an object.
- (void) moveTo:(SBObject *)to;  // Move an object to a new location.
- (void) assignTo:(id)to;  // Assign one or more tags to one or more notes.
- (void) unassignFrom:(id)from;  // Un-assign one or more tags from one or more notes.

@end

// A note.
@interface EvernoteNote : SBObject

- (SBElementArray *) attachments;

@property (copy) NSString *title;  // The note's title.
@property (copy) NSDate *creationDate;  // The note's creation date.
@property (copy) NSDate *modificationDate;  // The note's last modification date.
@property (copy) id subjectDate;  // The date associated with the note's content.
@property (copy) id sourceURL;  // The note's source URL.
@property (copy) id latitude;
@property (copy) id longitude;
@property (copy) id altitude;
@property (copy, readonly) NSString *ENMLContent;  // The note's content in ENML representation.
@property (copy) NSString *HTMLContent;  // The note's content in HTML representation.
@property (copy) NSArray *tags;  // The tags assigned to this note.
@property (copy, readonly) EvernoteNotebook *notebook;  // The notebook containing this note.
@property (copy, readonly) NSString *noteLink;  // A URL specifying this note. NOTE: if this note is in a synchronized notebook but has not yet been synchronized itself, the result will be nil.
@property (copy) id reminderTime;  // The reminder time for the note.
@property (copy) id reminderDoneTime;  // The time the reminder for the note was marked completed.

- (void) close;  // Close a window.
- (void) printWithProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) delete;  // Delete an object.
- (void) moveTo:(SBObject *)to;  // Move an object to a new location.
- (void) appendText:(NSString *)text html:(NSString *)html attachment:(NSURL *)attachment;  // Append data to an existing note.  You must specify exactly one of 'text', 'html', or 'attachment' parameters.

@end

// A note attachment.  Image, Audio, PDF, etc.
@interface EvernoteAttachment : SBObject

@property (copy) id filename;  // The attachment's original filename, if available.
@property (copy) NSString *mime;  // The attachment's mime type.
@property NSInteger size;  // The attachment's size in bytes.
@property (copy) id sourceURL;  // The attachment's source URL.
@property (copy) id latitude;
@property (copy) id longitude;
@property (copy) id altitude;
@property (copy, readonly) NSString *hash;  // The attachment's hash (used to identify the attachment in the note's ENML).
@property (copy, readonly) id recognitionData;  // Recognition data for this resource, if any.  Note that a resource will not have recognition data until it is provided by the service.  This XML data conforms to the following DTD: http://xml.evernote.com/pub/recoIndex.dtd

- (void) close;  // Close a window.
- (void) printWithProperties:(NSDictionary *)withProperties printDialog:(BOOL)printDialog;  // Print a document.
- (void) delete;  // Delete an object.
- (void) moveTo:(SBObject *)to;  // Move an object to a new location.
- (void) writeTo:(NSURL *)to;  // Write the attachment data to a file.

@end

