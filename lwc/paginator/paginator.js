import { LightningElement, api } from 'lwc';

export default class Paginator extends LightningElement {
    /** The current page number. */
    @api pageNumber;

    /** The number of items on a page. */
    @api pageSize;

    /** The total number of items in the list. */
    @api totalItemCount;

    /** Page Details */ 
    get pageDtl() {
        let pageLabel = this.totalItemCount === 0 ? 0 : this.pageNumber;
        pageLabel = pageLabel + ' of ' + this.totalPages; 
        return pageLabel; 
    }

    /** Per Page number of Records */ 
    get pageRecords() {
        return [
            { label: 1, value: 1 },
            { label: 5, value: 5 },
            { label: 10, value: 10 },
            { label: 15, value: 15 },
            { label: 25, value: 25 },
        ];
    }
    /** Total Item Count to be displayed */ 
    get totalCount() {
        let totalCountText = 'Total Products: ' + this.totalItemCount; 
        return totalCountText; 
    }

    renderedCallback() {
        let pgSize = this.pageSize;
        let optionSelect = this.template.querySelector(`[data-id="${pgSize}"]`);
        optionSelect.selected = true;
    }

    handlePrevious() {
        this.dispatchEvent(new CustomEvent('previous'));
    }

    handleNext() {
        this.dispatchEvent(new CustomEvent('next'));
    }

    handlePageSizeChange(event) {
        let pgSize = event.target.value;
        this.pageSize = pgSize;
        console.log('Page Size ' + this.pageSize);
        this.dispatchEvent(new CustomEvent('pagesize',{
            "detail": {"size":pgSize}}));
    }
    get currentPageNumber() {
        return this.totalItemCount === 0 ? 0 : this.pageNumber;
    }

    get isFirstPage() {
        return this.pageNumber === 1;
    }

    get isLastPage() {
        return this.pageNumber >= this.totalPages;
    }

    get totalPages() {
        return Math.ceil(this.totalItemCount / this.pageSize);
    }
}