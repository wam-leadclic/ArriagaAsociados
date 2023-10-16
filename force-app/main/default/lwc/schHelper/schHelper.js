import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const parseUrlParams = (urlParams, thisArgument) => {

    if(urlParams) {

        // read url params only one time
        if(thisArgument.attendeeId === undefined || thisArgument.attendeeId === '') {

            for(let param of Object.keys(urlParams)) {
                try {
                    let isFilter = false;
                    let attKey = param.replace(/c__/, '');
                    // The filters in the URL has the format: c__f_Filter
                    if (attKey.startsWith('f_')){
                        attKey = attKey.replace(/f_/, '');
                        attKey = attKey + '__c';  
                        isFilter = true;
                    }
    
                    if(Array.isArray(thisArgument[attKey])) {
                        let lParamSplit = urlParams[param] ? urlParams[param].split(',') : [];
                        for (let paramSplit of lParamSplit){
                            if (isFilter){
                                thisArgument.filterValues[attKey].push(paramSplit);
                            }else{
                                thisArgument[attKey].push(paramSplit);
                            }
                        }
                       
                    } else {
                        if (isFilter){
                            thisArgument.filterValues[attKey] = urlParams[param];
                        }else {   
                            thisArgument[attKey] = urlParams[param];
                        }
                    }
    
                } catch (exception) {
                    console.log('Exception: URL parameter parsing error on ' + param + ': '+exception);
                }
            }
        }  
    } 
}


const showToast  = (payload, thisArgument) => {

    const showError = new ShowToastEvent({
        title: payload.title,
        message: payload.message,
        variant: payload.variant,
    });
    thisArgument.dispatchEvent(showError);       

}

export {
    parseUrlParams, 
    showToast
};