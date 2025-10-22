/*************************************************
 *  Custom Publication Filter with Text-based Hashes
 *  Override for Hugo Blox Builder Publications
 **************************************************/

// Mapping from publication type numbers to text slugs
const pubtypeHashMap = {
  '1': 'conference-papers',
  '2': 'journal-articles', 
  '3': 'preprints',
  '6': 'book-sections'
};

// Reverse mapping from text slugs to publication type numbers
const hashPubtypeMap = {
  'conference-papers': '1',
  'journal-articles': '2',
  'preprints': '3', 
  'book-sections': '6'
};

// Override the publication filter change handler
$(document).ready(function() {
  // Remove existing handler and add custom one
  $('.pub-filters[data-filter-group="pubtype"]').off('change').on('change', function () {
    let $this = $(this);
    let filterGroup = $this[0].getAttribute('data-filter-group');
    
    // Set filter for group
    if (typeof pubFilters !== 'undefined') {
      pubFilters[filterGroup] = this.value;
      
      // Combine filters
      if (typeof concatValues === 'function') {
        filterValues = concatValues(pubFilters);
      }
      
      // Activate filters
      if (typeof $grid_pubs !== 'undefined' && $grid_pubs.length) {
        $grid_pubs.isotope();
      }
    }

    // Custom hash URL logic for publication type
    if (filterGroup === 'pubtype') {
      let url = $(this).val();
      if (url.substr(0, 9) === '.pubtype-') {
        let typeNumber = url.substr(9);
        let textHash = pubtypeHashMap[typeNumber] || typeNumber;
        window.location.hash = textHash;
      } else {
        window.location.hash = '';
      }
    }
  });
});

// Override the filter_publications function to handle text-based hashes
function filter_publications_custom() {
  // Check for Isotope publication layout
  if (typeof $grid_pubs === 'undefined' || !$grid_pubs.length) return;

  let urlHash = window.location.hash.replace('#', '');
  let filterValue = '*';

  // Check if hash is set
  if (urlHash != '') {
    // Convert text hash to number if needed
    let typeNumber = hashPubtypeMap[urlHash] || urlHash;
    filterValue = '.pubtype-' + typeNumber;
  }

  // Set filter
  let filterGroup = 'pubtype';
  if (typeof pubFilters !== 'undefined') {
    pubFilters[filterGroup] = filterValue;
    
    if (typeof concatValues === 'function') {
      filterValues = concatValues(pubFilters);
    }

    // Activate filters
    $grid_pubs.isotope();

    // Set selected option
    $('.pubtype-select').val(filterValue);
  }
}

// Override the original filter_publications function when DOM is loaded
document.addEventListener('DOMContentLoaded', function () {
  // Wait a bit to ensure original code has run
  setTimeout(function() {
    if ($('.pub-filters-select').length) {
      filter_publications_custom();
      
      // Enable hash change detection for manual URL changes
      window.addEventListener('hashchange', filter_publications_custom, false);
    }
  }, 100);
});