
const express = require('express');
const pool = require('./mysql');

const app = express();
const port = 3000;

// GET route for searching books
app.get('/', async (req, res) => {

    // Extract parameters from the URL
    const { category, author, format } = req.query;

    // Create the SQL query
    let sql = 'SELECT * FROM books WHERE 1=1';
    const params = [];

    // Search by category if provided
    if (category) {
        sql += ' AND category = ?';
        params.push(category);
    }

    // Search by author if provided
    if (author) {
        sql += ' AND author = ?';
        params.push(author);
    }

    try {
        // Execute the query
        const [books] = await pool.execute(sql, params);

        // Return HTML if text format is requested
        if (format === 'text') {
            let html = '<h1>Book Results</h1>';

            if (books.length === 0) {
                html += '<p>No books found.</p>';
            }

            books.forEach(book => {
                html += `
                    <p>
                        ${escapeHtml(book.title)} -
                        ${escapeHtml(book.author)} -
                        ${escapeHtml(book.category)} -
                        $${book.price}
                    </p>
                `;
            });

            return res.type('html').send(html);
        }

        // Return JSON by default
        res.json(books);

    } catch (error) {
        // Handle database errors
        console.error('Database error:', error);

        res.status(500).json({
            error: 'Database query failed'
        });
    }
});

// Escape special characters for HTML output
function escapeHtml(value) {
    return String(value).replace(/[&<>"']/g, char => ({
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#39;'
    })[char]);
}

// Start the server
app.listen(port, () => {
    console.log(`Server running at http://localhost:${port}`);
});
