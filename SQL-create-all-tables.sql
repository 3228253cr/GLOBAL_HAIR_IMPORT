-- ===========================================
-- Global Imports CRM - יצירת כל הטבלאות
-- הרץ את הקוד הזה ב-SQL Editor ב-Supabase
-- ===========================================

-- 1. טבלת ספקים
CREATE TABLE IF NOT EXISTS suppliers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    contact_name TEXT,
    phone TEXT,
    email TEXT,
    country TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
ALTER TABLE suppliers DISABLE ROW LEVEL SECURITY;

-- 2. טבלת מוצרים (עודכן)
CREATE TABLE IF NOT EXISTS products (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    product_date DATE DEFAULT CURRENT_DATE,
    supplier_id UUID REFERENCES suppliers(id) ON DELETE SET NULL,
    product_type TEXT DEFAULT 'שיער',
    price NUMERIC(10,2) DEFAULT 0,
    quantity INTEGER DEFAULT 0,
    discount NUMERIC(10,2) DEFAULT 0,
    subtotal_price NUMERIC(10,2) DEFAULT 0,
    total_price NUMERIC(10,2) DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
ALTER TABLE products DISABLE ROW LEVEL SECURITY;

-- הוספת עמודות חדשות למוצרים אם לא קיימות
ALTER TABLE products ADD COLUMN IF NOT EXISTS product_date DATE DEFAULT CURRENT_DATE;
ALTER TABLE products ADD COLUMN IF NOT EXISTS discount NUMERIC(10,2) DEFAULT 0;
ALTER TABLE products ADD COLUMN IF NOT EXISTS subtotal_price NUMERIC(10,2) DEFAULT 0;
ALTER TABLE products ADD COLUMN IF NOT EXISTS quantity_a INTEGER DEFAULT 0;
ALTER TABLE products ADD COLUMN IF NOT EXISTS quantity_b INTEGER DEFAULT 0;

-- 3. טבלת תשלומי מוצרים (חדש)
CREATE TABLE IF NOT EXISTS product_payments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    product_id UUID REFERENCES products(id) ON DELETE CASCADE,
    payment_date DATE DEFAULT CURRENT_DATE,
    amount NUMERIC(10,2) NOT NULL,
    payment_method TEXT,
    reference_number TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
ALTER TABLE product_payments DISABLE ROW LEVEL SECURITY;

-- 4. טבלת לקוחות
CREATE TABLE IF NOT EXISTS customers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    company_name TEXT NOT NULL,
    contact_name TEXT,
    phone TEXT,
    phone2 TEXT,
    email TEXT,
    address TEXT,
    work_address TEXT,
    tax_id TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
ALTER TABLE customers DISABLE ROW LEVEL SECURITY;

-- הוספת עמודות חדשות ללקוחות אם לא קיימות
ALTER TABLE customers ADD COLUMN IF NOT EXISTS phone2 TEXT;
ALTER TABLE customers ADD COLUMN IF NOT EXISTS work_address TEXT;

-- 5. טבלת הזמנות
CREATE TABLE IF NOT EXISTS orders (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    order_number TEXT,
    customer_id UUID REFERENCES customers(id) ON DELETE SET NULL,
    order_date DATE DEFAULT CURRENT_DATE,
    status TEXT DEFAULT 'פתוח',
    payment_terms TEXT DEFAULT 'שוטף+30',
    payment_method TEXT DEFAULT 'העברה בנקאית',
    discount NUMERIC(10,2) DEFAULT 0,
    include_vat BOOLEAN DEFAULT FALSE,
    vat_amount NUMERIC(10,2) DEFAULT 0,
    manual_invoice BOOLEAN DEFAULT FALSE,
    manual_invoice_number TEXT,
    total_amount NUMERIC(10,2) DEFAULT 0,
    paid_amount NUMERIC(10,2) DEFAULT 0,
    balance NUMERIC(10,2) DEFAULT 0,
    payment_status TEXT DEFAULT 'לא שולם',
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
ALTER TABLE orders DISABLE ROW LEVEL SECURITY;

-- הוספת עמודות חדשות להזמנות אם לא קיימות
ALTER TABLE orders ADD COLUMN IF NOT EXISTS discount NUMERIC(10,2) DEFAULT 0;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS include_vat BOOLEAN DEFAULT FALSE;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS vat_amount NUMERIC(10,2) DEFAULT 0;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS manual_invoice BOOLEAN DEFAULT FALSE;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS manual_invoice_number TEXT;

-- 6. טבלת פריטי הזמנה
CREATE TABLE IF NOT EXISTS order_items (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES products(id) ON DELETE SET NULL,
    product_type TEXT,
    quantity INTEGER DEFAULT 1,
    unit_price NUMERIC(10,2) DEFAULT 0,
    total_price NUMERIC(10,2) DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
ALTER TABLE order_items DISABLE ROW LEVEL SECURITY;

-- הוספת עמודת product_type לפריטי הזמנה
ALTER TABLE order_items ADD COLUMN IF NOT EXISTS product_type TEXT;

-- 7. טבלת חשבוניות
CREATE TABLE IF NOT EXISTS invoices (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    invoice_number TEXT,
    order_id UUID REFERENCES orders(id) ON DELETE SET NULL,
    customer_id UUID REFERENCES customers(id) ON DELETE SET NULL,
    invoice_date DATE DEFAULT CURRENT_DATE,
    due_date DATE,
    subtotal NUMERIC(10,2) DEFAULT 0,
    vat_amount NUMERIC(10,2) DEFAULT 0,
    total_amount NUMERIC(10,2) DEFAULT 0,
    status TEXT DEFAULT 'ממתין לתשלום',
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
ALTER TABLE invoices DISABLE ROW LEVEL SECURITY;

-- 8. טבלת תשלומים (עם תמיכה במטבעות)
CREATE TABLE IF NOT EXISTS payments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    customer_id UUID REFERENCES customers(id) ON DELETE CASCADE,
    payment_date DATE DEFAULT CURRENT_DATE,
    amount NUMERIC(10,2) NOT NULL,
    currency TEXT DEFAULT 'ILS',
    exchange_rate NUMERIC(10,4) DEFAULT 1,
    amount_ils NUMERIC(10,2) NOT NULL,
    payment_method TEXT,
    reference_number TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
ALTER TABLE payments DISABLE ROW LEVEL SECURITY;

-- 9. טבלת משתמשים
CREATE TABLE IF NOT EXISTS users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    username TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    role TEXT DEFAULT 'user',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
ALTER TABLE users DISABLE ROW LEVEL SECURITY;

-- 10. טבלת דוחות נסיעה (חדש)
CREATE TABLE IF NOT EXISTS trip_reports (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    report_number INTEGER UNIQUE NOT NULL,
    date_from DATE NOT NULL,
    date_to DATE NOT NULL,
    flight_cost NUMERIC(10,2) DEFAULT 0,
    hotel_cost NUMERIC(10,2) DEFAULT 0,
    other_cost NUMERIC(10,2) DEFAULT 0,
    total_expenses NUMERIC(10,2) DEFAULT 0,
    total_qty INTEGER DEFAULT 0,
    total_products NUMERIC(10,2) DEFAULT 0,
    total_trip NUMERIC(10,2) DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
ALTER TABLE trip_reports DISABLE ROW LEVEL SECURITY;

-- 11. טבלת נסיעות
CREATE TABLE IF NOT EXISTS trips (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    date_from DATE NOT NULL,
    date_to DATE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
ALTER TABLE trips DISABLE ROW LEVEL SECURITY;

-- 12. טבלת הוצאות נסיעה
CREATE TABLE IF NOT EXISTS trip_expenses (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    trip_id UUID REFERENCES trips(id) ON DELETE CASCADE,
    expense_type TEXT NOT NULL,
    amount NUMERIC(10,2) DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
ALTER TABLE trip_expenses DISABLE ROW LEVEL SECURITY;

-- הוספת משתמשי ברירת מחדל
INSERT INTO users (username, password, role) VALUES 
    ('admin', 'admin123', 'admin'),
    ('rivky', 'rab2025', 'admin')
ON CONFLICT (username) DO NOTHING;

-- ===========================================
-- טריגר לעדכון סטטוס תשלום בהזמנה
-- ===========================================
CREATE OR REPLACE FUNCTION update_order_payment_status()
RETURNS TRIGGER AS $$
DECLARE
    total_paid NUMERIC(10,2);
    order_total NUMERIC(10,2);
BEGIN
    SELECT COALESCE(SUM(amount_ils), 0) INTO total_paid
    FROM payments WHERE order_id = COALESCE(NEW.order_id, OLD.order_id);
    
    SELECT total_amount INTO order_total
    FROM orders WHERE id = COALESCE(NEW.order_id, OLD.order_id);
    
    UPDATE orders SET 
        paid_amount = total_paid,
        balance = COALESCE(order_total, 0) - total_paid,
        payment_status = CASE 
            WHEN total_paid >= COALESCE(order_total, 0) THEN 'שולם במלואו'
            WHEN total_paid > 0 THEN 'שולם חלקית'
            ELSE 'לא שולם'
        END
    WHERE id = COALESCE(NEW.order_id, OLD.order_id);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_payment_status ON payments;
CREATE TRIGGER trigger_update_payment_status
    AFTER INSERT OR UPDATE OR DELETE ON payments
    FOR EACH ROW
    EXECUTE FUNCTION update_order_payment_status();

-- ===========================================
SELECT 'כל הטבלאות נוצרו בהצלחה!' as message;
