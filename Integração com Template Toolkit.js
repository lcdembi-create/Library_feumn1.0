// language-selector.js
function changeLanguage(lang) {
    // Salvar preferência
    localStorage.setItem('preferred_language', lang);
    
    // Recarregar página com novo idioma
    const url = new URL(window.location.href);
    url.searchParams.set('lang', lang);
    window.location.href = url.toString();
}

// Detectar idioma preferido
document.addEventListener('DOMContentLoaded', function() {
    const savedLang = localStorage.getItem('preferred_language');
    const browserLang = navigator.language.split('-')[0];
    const supported = ['pt', 'en', 'fr'];
    
    if (savedLang && supported.includes(savedLang)) {
        if (!window.location.search.includes('lang=')) {
            changeLanguage(savedLang);
        }
    } else if (supported.includes(browserLang)) {
        changeLanguage(browserLang);
    }
});