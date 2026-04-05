// Custom JavaScript for Sentiment Dashboard
// Animations and live updates

$(document).ready(function() {
    console.log("Dashboard initialized - Ready for sentiment analysis");
    
    // Fix: Wait for DataTable to initialize before trying to control it
    setTimeout(function() {
        if ($.fn.dataTable.isDataTable('#tweet_table')) {
            console.log("DataTable is ready");
        } else {
            console.log("DataTable not yet initialized");
        }
    }, 1000);
});

// Add CSS animation
var style = document.createElement('style');
style.textContent = `
    .pulse-animation {
        animation: numberPulse 0.5s ease;
    }
    
    @keyframes numberPulse {
        0% { transform: scale(1); color: #00ff88; }
        50% { transform: scale(1.2); color: #ffffff; }
        100% { transform: scale(1); color: #00ff88; }
    }
`;
document.head.appendChild(style);