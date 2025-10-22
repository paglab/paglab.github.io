/*************************************************
 *  Custom Publication Filter with Text-based Hashes
 *  Override for Hugo Blox Builder Publications
 **************************************************/

// Mapping from publication type numbers to text slugs
const pubtypeHashMap = {
  '0': 'uncategorized',
  '1': 'conference-paper',
  '2': 'journal-article', 
  '3': 'preprint',
  '4': 'report',
  '5': 'book',
  '6': 'book-section',
  '7': 'thesis',
  '8': 'patent'
};

// Reverse mapping from text slugs to publication type numbers
const hashPubtypeMap = {
  'uncategorized': '0',
  'conference-paper': '1',
  'journal-article': '2',
  'preprint': '3',
  'report': '4',
  'book': '5',
  'book-section': '6',
  'thesis': '7',
  'patent': '8'
};

// Store references to the original filtering system
let originalPubFilters = {};
let originalSearchRegex = null;

// Wait for the original publication script to load and initialize
document.addEventListener('DOMContentLoaded', function () {
  // Wait for the original script to fully initialize
  setTimeout(function() {
    initCustomPublicationFilter();
  }, 300);
});

function initCustomPublicationFilter() {
  const $grid_pubs = $('#container-publications');
  
  if (!$grid_pubs.length) {
    console.log('Publication grid not found');
    return;
  }

  console.log('Initializing custom publication filter...');

  // Override only the pubtype filter handler, preserve others
  $('.pub-filters[data-filter-group="pubtype"]').off('change').on('change', function () {
    const $this = $(this);
    const filterGroup = $this[0].getAttribute('data-filter-group');
    
    // Set filter for this group
    originalPubFilters[filterGroup] = this.value;
    
    // Apply all filters (including search)
    applyAllFilters();

    // Custom hash URL logic for publication type only
    if (filterGroup === 'pubtype') {
      const url = $(this).val();
      if (url.substr(0, 9) === '.pubtype-') {
        const typeNumber = url.substr(9);
        const textHash = pubtypeHashMap[typeNumber] || typeNumber;
        window.location.hash = textHash;
      } else {
        window.location.hash = '';
      }
    }
  });

  // Preserve the date filter functionality
  $('.pub-filters[data-filter-group="year"]').off('change').on('change', function () {
    const $this = $(this);
    const filterGroup = $this[0].getAttribute('data-filter-group');
    originalPubFilters[filterGroup] = this.value;
    applyAllFilters();
  });

  // Preserve the search functionality
  $('.filter-search').off('keyup').on('keyup', debounce(function () {
    originalSearchRegex = new RegExp($(this).val(), 'gi');
    applyAllFilters();
  }, 100));

  // Handle initial hash-based filtering on page load
  filterPublicationsFromHash();
  
  // Handle hash changes (e.g., manual URL editing)
  window.addEventListener('hashchange', filterPublicationsFromHash, false);
}

function applyAllFilters() {
  const $grid_pubs = $('#container-publications');
  
  if (!$grid_pubs.length || !$grid_pubs.data('isotope')) return;

  // Combine all filter values
  let combinedFilters = '';
  for (let prop in originalPubFilters) {
    combinedFilters += originalPubFilters[prop];
  }

  // Apply the combined filter including search
  $grid_pubs.isotope({
    filter: function () {
      const $this = $(this);
      const searchResults = originalSearchRegex ? $this.text().match(originalSearchRegex) : true;
      const filterResults = combinedFilters ? $this.is(combinedFilters) : true;
      return searchResults && filterResults;
    }
  });
}

function filterPublicationsFromHash() {
  const $grid_pubs = $('#container-publications');
  
  if (!$grid_pubs.length) return;

  const urlHash = window.location.hash.replace('#', '');
  let filterValue = '*';

  // Check if hash is set
  if (urlHash !== '') {
    // Convert text hash to number if needed
    const typeNumber = hashPubtypeMap[urlHash] || urlHash;
    filterValue = '.pubtype-' + typeNumber;
  }

  // Set the dropdown selection
  $('.pubtype-select').val(filterValue);
  
  // Update the filter state
  originalPubFilters['pubtype'] = filterValue;

  // Apply all filters
  applyAllFilters();
}

// Debounce function for search
function debounce(fn, threshold) {
  let timeout;
  threshold = threshold || 100;
  return function debounced() {
    clearTimeout(timeout);
    let args = arguments;
    let _this = this;

    function delayed() {
      fn.apply(_this, args);
    }

    timeout = setTimeout(delayed, threshold);
  };
}