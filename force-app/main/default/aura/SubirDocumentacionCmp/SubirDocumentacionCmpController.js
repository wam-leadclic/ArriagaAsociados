({
    handleUploadFinished: function (cmp, event) {
        // This will contain the List of File uploaded data and status
        var uploadedFiles = event.getParam("files");
        //alert("Files uploaded : " + uploadedFiles.length);
        
        //variable tipo lista para mandarlo a las variables de salida
        var idsDoc=[]; var nameDoc=[];
        for (var i = 0; i < uploadedFiles.length; i++) {
            idsDoc.push(uploadedFiles[i].documentId);
            nameDoc.push(uploadedFiles[i].name);
        }
        cmp.set('v.idDocumento', idsDoc);
        cmp.set('v.nombreDocumento', nameDoc);
        cmp.set('v.Cargado', true);
    }
})