document.addEventListener('DOMContentLoaded', function() {
  // Map of tag values to display names
  const labelMap = {
    '2': 'Journal Article',
    '1': 'Conference Paper',
    '3': 'Preprint',
    '4': 'Thesis',
    '5': 'Book',
    '6': 'Book Section',
    '0': 'Other'
  };
  
  // Apply labels to all filter buttons
  document.querySelectorAll('.pub-filter').forEach(btn => {
    const filterValue = btn.dataset.filter;
    if (labelMap[filterValue]) {
      btn.textContent = labelMap[filterValue];
    }
  });
});