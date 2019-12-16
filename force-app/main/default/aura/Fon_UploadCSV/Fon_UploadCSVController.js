({  
    handleFileClick:function(component, event, helper){
        component.set("v.fileName", $A.get("$Label.c.Fon_NoFileSelected"));
    },
    handleFilesChange: function(component, event, helper) {
        var fileName = '';
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
            component.set("v.disable","false");
            component.set("v.fileName", fileName);
        }
    },
    handleClick : function(component, event, helper) {
        component.set("v.Spinner", true); 
        if (component.find("fileId").get("v.files").length > 0) {
            var filename = component.find("fileId").get("v.files");
            var textdata;
            var reader = new FileReader();
            var infolst = [];
            var isExtraCommafound = false;
            reader.onload = function() {
                var text = reader.result; 
                textdata = text;
                var rows = textdata.split('\n'); 
                helper.csvFileUploader(component, event, helper, text); 
            };
            if (filename[0] !== undefined && filename[0] !== null && filename[0] !== '') {
                reader.readAsText(filename[0]);
            }else{
                alert($A.get("$Label.c.Fon_SelectValidFile"));
            }
        } else {
            alert($A.get("$Label.c.Fon_SelectValidFile"));
        }
    },
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
        component.set("v.Spinner", true); 
    },
    
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
        // make Spinner attribute to false for hide loading spinner    
        component.set("v.Spinner", false);
    },
    
    onCheckedBox: function(component, event, helper) {
        alert('onCheckedBox');
    }
})