// Mobile menu toggle
function toggleMenu() {
    const navLinks = document.getElementById('navLinks');
    const menuIcon = document.getElementById('menuIcon');
    const menuBtn = document.querySelector('.mobile-menu-btn');

    navLinks.classList.toggle('active');

    if (navLinks.classList.contains('active')) {
        menuIcon.classList.remove('fa-bars');
        menuIcon.classList.add('fa-times');
        menuBtn.style.transform = 'rotate(90deg)';
    } else {
        menuIcon.classList.remove('fa-times');
        menuIcon.classList.add('fa-bars');
        menuBtn.style.transform = 'rotate(0deg)';
    }
}

// Scroll reveal animations
const observerOptions = {
    threshold: 0.1,
    rootMargin: '0px 0px -100px 0px'
};

const observer = new IntersectionObserver((entries) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.classList.add('visible');
        }
    });
}, observerOptions);

document.querySelectorAll('.fade-in-section').forEach((el) => {
    observer.observe(el);
});

// Header scroll effect
const header = document.getElementById('header');
let lastScroll = 0;

window.addEventListener('scroll', () => {
    const currentScroll = window.pageYOffset;

    if (currentScroll > 100) {
        header.classList.add('scrolled');
    } else {
        header.classList.remove('scrolled');
    }

    lastScroll = currentScroll;
});

// Cookie banner
if (!localStorage.getItem('cookiesAccepted')) {
    setTimeout(() => {
        document.getElementById('cookieBanner').style.display = 'block';
    }, 1500);
}

function acceptCookies() {
    localStorage.setItem('cookiesAccepted', 'true');
    const banner = document.getElementById('cookieBanner');
    banner.style.animation = 'slideUp 0.4s cubic-bezier(0.4, 0, 0.2, 1) reverse';
    setTimeout(() => {
        banner.style.display = 'none';
    }, 400);
}

// Smooth scroll for anchor links
document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
        const href = this.getAttribute('href');
        if (href !== '#') {
            e.preventDefault();
            const target = document.querySelector(href);
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth',
                    block: 'start'
                });
            }
        }
    });
});

// Show desktop CTA button on larger screens
const updateNavCTA = () => {
    const navCTA = document.querySelector('.nav-cta-btn');
    if (window.innerWidth >= 1024) {
        navCTA.style.display = 'inline-flex';
    } else {
        navCTA.style.display = 'none';
    }
};

updateNavCTA();
window.addEventListener('resize', updateNavCTA);
