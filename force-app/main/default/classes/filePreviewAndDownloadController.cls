public with sharing class filePreviewAndDownloadController {
    
    public class File{
        @AuraEnabled public string Extension;
        @AuraEnabled public string Title;
        @AuraEnabled public string Size;
        @AuraEnabled public string CreatedDate;
        @AuraEnabled public string Link;
        @AuraEnabled public string IconName;
        @AuraEnabled public string Id;
        
        public File(string aLink,string anExtension, string aTitle, string aSize, DateTime aCreatedDate){
            Extension = anExtension;
            Title = aTitle;
            Size = aSize;
            CreatedDate = aCreatedDate.format('MMM d,YYYY');
            IconName = 'doctype:'+anExtension;
            Id = aLink;
        }

    }

    @AuraEnabled(cacheable=true)
    public static List<File> getRelatedFilesOF(String recordId){
        List<File> result = new List<File>();
        for( ContentDocumentLink docLink : [SELECT ContentDocumentId, ContentDocument.FileExtension, ContentDocument.Title, ContentDocument.ContentSize, ContentDocument.CreatedDate FROM ContentDocumentLink WHERE LinkedEntityId = :recordId] ){
            result.Add(
                new File(
                    docLink.ContentDocumentId , 
                    docLink.ContentDocument.FileExtension, 
                    docLink.ContentDocument.Title, 
                    ''+docLink.ContentDocument.ContentSize, 
                    docLink.ContentDocument.CreatedDate
                    )
                );
        }
        return result;
    }
/*
    @AuraEnabled(cacheable=true)
    public static Map<ID, String> getRelatedFilesByRecordId(String recordId) {
        // Get record file IDs        
        List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
        List<ID> fileIDs = new List<ID>();
        for (ContentDocumentLink docLink : files) {
            fileIDs.add(docLink.ContentDocumentId);
        }
 
        List<ContentVersion> docs = [SELECT ContentDocumentId, FileExtension, Title, ContentSize, CreatedDate 
            FROM ContentVersion WHERE ContentDocumentId IN : fileIDs];
        Map<ID, String> mapIdTitle = new Map<ID, String>();
        for (ContentVersion docLink : docs) {
            mapIdTitle.put(docLink.ContentDocumentId, docLink.Title);
        }
        return mapIdTitle;
    }
*/
    @AuraEnabled
    public static List<File> linkFilesWithRecord(String recordId, List<String> fileIdsToLink){
        ContentDocumentLink newLink;
        List<ContentDocumentLink> newLinks = new List<ContentDocumentLink>();
        for(String fileToLinkId : fileIdsToLink){
            newLink = new ContentDocumentLink();
            newLink.ContentDocumentId = fileToLinkId;
            newLink.LinkedEntityId = recordId;
            newLinks.Add(newLink);
        }
        insert newLinks;

        List<File> result = new List<File>();
        for( ContentDocumentLink docLink : [SELECT ContentDocumentId, ContentDocument.FileExtension, ContentDocument.Title, ContentDocument.ContentSize, ContentDocument.CreatedDate FROM ContentDocumentLink WHERE LinkedEntityId = :recordId] ){
            result.Add(new File(docLink.ContentDocumentId , docLink.ContentDocument.FileExtension, docLink.ContentDocument.Title, ''+docLink.ContentDocument.ContentSize, docLink.ContentDocument.CreatedDate));
        }
        return result;
    }

    @AuraEnabled
    public static List<File> removeFileRecord(String recordId, String fileId){
        
        //System.Debug('removeFileRecord recordId:'+recordId+' fileId:'+fileId);
        List<ContentDocument> docsToDelete = [SELECT Id FROM ContentDocument WHERE Id =: fileId];
        //System.Debug('docsToDelete: '+docsToDelete);
        if(docsToDelete.size() > 0){
            //System.Debug('DOC DELETED');
            Database.delete(docsToDelete, false);
            //Database.emptyRecycleBin(docsToDelete);
        }
        

        List<File> result = new List<File>();
        for( ContentDocumentLink docLink : [SELECT ContentDocumentId, ContentDocument.FileExtension, ContentDocument.Title, ContentDocument.ContentSize, ContentDocument.CreatedDate FROM ContentDocumentLink WHERE LinkedEntityId = :recordId] ){
            result.Add(new File(docLink.ContentDocumentId , docLink.ContentDocument.FileExtension, docLink.ContentDocument.Title, ''+docLink.ContentDocument.ContentSize, docLink.ContentDocument.CreatedDate));
        }
        return result;
    }
}