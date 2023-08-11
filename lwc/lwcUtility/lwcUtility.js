import { ShowToastEvent } from 'lightning/platformShowToastEvent';

const showMessage = (page, title, message, type, msgMode) => {
    msgMode = msgMode ? msgMode : "dismissible";
    const toastEvt = new ShowToastEvent({
        title: title,
        message:message,
        variant: type,
        mode : msgMode
    });
    page.dispatchEvent(toastEvt);
};

const sortByArray = (field, reverse, primer) => {
    const key = primer
        ? function (x) {
            return primer(x[field]);
        }
        : function (x) {
            return x[field];
        };

    return function (a, b) {
        a = key(a);
        b = key(b);
        return reverse * ((a > b) - (b > a));
    };
}

export {
    showMessage,
    sortByArray
}