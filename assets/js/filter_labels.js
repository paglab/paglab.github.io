document.addEventListener('DOMContentLoaded', function() {
  // Map of tag values to display names
  const labelMap = {
    '2': 'Journal Articles',
    '1': 'Conference Papers',
    '3': 'Preprints',
    '4': 'Theses',
    '5': 'Books',
    '6': 'Book Sections',
    '0': 'Other'
  };
  
  // Apply labels to all filter buttons
  document.querySelectorAll('[data-filter]').forEach(btn => {
    const filterValue = btn.dataset.filter.replace(/"/g, '');
    if (labelMap[filterValue]) {
      btn.textContent = labelMap[filterValue];
      btn.setAttribute('aria-label', labelMap[filterValue]);
    }
  });
});