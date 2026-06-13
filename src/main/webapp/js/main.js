/* ============================================================
   main.js — Course Management Portal
   ============================================================ */

'use strict';

/* ── 1. Login Page: Admin / Student Tab Switch ─────────── */
function switchRole(role) {
    const roleInput      = document.getElementById('roleInput');
    const studentFields  = document.getElementById('studentFields');
    const adminFields    = document.getElementById('adminFields');
    const registerLink   = document.getElementById('registerLink');
    const studentTab     = document.getElementById('student-tab');
    const adminTab       = document.getElementById('admin-tab');

    if (!roleInput) return;

    roleInput.value = role;

    if (role === 'admin') {
        studentFields && (studentFields.style.display = 'none');
        adminFields   && (adminFields.style.display   = 'block');
        registerLink  && (registerLink.style.display  = 'none');
        studentTab && studentTab.classList.remove('active');
        adminTab   && adminTab.classList.add('active');
    } else {
        studentFields && (studentFields.style.display = 'block');
        adminFields   && (adminFields.style.display   = 'none');
        registerLink  && (registerLink.style.display  = 'block');
        studentTab && studentTab.classList.add('active');
        adminTab   && adminTab.classList.remove('active');
    }
}

/* ── 2. Delete Confirmation Modal ───────────────────────── */
(function initDeleteModal() {
    const modal = document.getElementById('deleteModal');
    if (!modal) return;

    let pendingUrl = null;

    // Catch all delete buttons
    document.querySelectorAll('[data-delete-url]').forEach(btn => {
        btn.addEventListener('click', e => {
            e.preventDefault();
            pendingUrl = btn.dataset.deleteUrl;
            const label = btn.dataset.deleteLabel || 'this record';
            const msg = document.getElementById('deleteModalMessage');
            if (msg) msg.textContent = `Are you sure you want to delete "${label}"? This action cannot be undone.`;
            const bsModal = new bootstrap.Modal(modal);
            bsModal.show();
        });
    });

    const confirmBtn = document.getElementById('confirmDeleteBtn');
    if (confirmBtn) {
        confirmBtn.addEventListener('click', () => {
            if (pendingUrl) window.location.href = pendingUrl;
        });
    }
})();

/* ── 3. Toast Notifications ─────────────────────────────── */
function showToast(message, type = 'info') {
    const container = document.getElementById('toastContainer');
    if (!container) return;

    const id = 'toast-' + Date.now();
    const iconMap = { success: '✅', danger: '❌', info: 'ℹ️', warning: '⚠️' };
    const icon = iconMap[type] || 'ℹ️';

    const html = `
      <div id="${id}" class="toast toast-custom toast-${type} show align-items-center border-0 mb-2" role="alert" aria-live="assertive">
        <div class="d-flex">
          <div class="toast-body d-flex align-items-center gap-2">
            <span>${icon}</span> ${message}
          </div>
          <button type="button" class="btn-close me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
        </div>
      </div>`;

    container.insertAdjacentHTML('beforeend', html);
    const el = document.getElementById(id);
    setTimeout(() => {
        if (el) { el.classList.remove('show'); setTimeout(() => el.remove(), 400); }
    }, 4000);
}

// Auto-show toast based on URL msg param
(function autoToast() {
    const params = new URLSearchParams(window.location.search);
    const msg    = params.get('msg');
    if (!msg) return;
    const map = {
        added:           ['Course added successfully!',        'success'],
        updated:         ['Record updated successfully!',      'success'],
        deleted:         ['Record deleted successfully!',      'success'],
        removed:         ['Enrollment removed successfully!',  'success'],
        enrolled:        ['Successfully enrolled in course!',  'success'],
        alreadyEnrolled: ['You are already enrolled in this course.', 'warning'],
        error:           ['An error occurred. Please try again.', 'danger'],
    };
    if (map[msg]) showToast(map[msg][0], map[msg][1]);

    // Clean URL without reload
    const url = new URL(window.location.href);
    url.searchParams.delete('msg');
    history.replaceState({}, '', url.toString());
})();

/* ── 4. Live Table Search (client-side) ─────────────────── */
(function initTableSearch() {
    const input = document.getElementById('tableSearch');
    if (!input) return;

    input.addEventListener('input', function () {
        const q = this.value.toLowerCase().trim();
        const rows = document.querySelectorAll('table tbody tr');
        let visible = 0;

        rows.forEach(row => {
            const text = row.textContent.toLowerCase();
            const show = text.includes(q);
            row.style.display = show ? '' : 'none';
            if (show) visible++;
        });

        // Show empty state if no rows visible
        const empty = document.getElementById('tableEmpty');
        if (empty) empty.style.display = visible === 0 ? 'block' : 'none';

        // Update count badge
        const countBadge = document.getElementById('rowCount');
        if (countBadge) countBadge.textContent = visible;
    });
})();

/* ── 5. Client-Side Form Validation ─────────────────────── */
(function initFormValidation() {
    // Bootstrap 5 native validation styles
    document.querySelectorAll('form[data-validate]').forEach(form => {
        form.addEventListener('submit', function (e) {
            if (!this.checkValidity()) {
                e.preventDefault();
                e.stopPropagation();
            }
            this.classList.add('was-validated');
        });
    });

    // Password match check (register page)
    const pass    = document.getElementById('password');
    const confirm = document.getElementById('confirmPassword');
    if (pass && confirm) {
        const check = () => {
            if (confirm.value && pass.value !== confirm.value) {
                confirm.setCustomValidity('Passwords do not match.');
            } else {
                confirm.setCustomValidity('');
            }
        };
        pass.addEventListener('input', check);
        confirm.addEventListener('input', check);
    }
})();

/* ── 6. Fees / Numeric Field Formatting ─────────────────── */
(function initFeesField() {
    const feesInput = document.getElementById('feesInput');
    if (!feesInput) return;
    feesInput.addEventListener('blur', function () {
        const val = parseFloat(this.value);
        if (!isNaN(val)) this.value = val.toFixed(2);
    });
})();

/* ── 7. Sidebar / Navbar Active Link Highlighting ────────── */
(function highlightNavLink() {
    const path = window.location.pathname + window.location.search;
    document.querySelectorAll('.nav-link[href]').forEach(link => {
        const href = link.getAttribute('href');
        if (href && path.includes(href.split('?')[0]) && href !== '#') {
            link.classList.add('active');
        }
    });
})();
