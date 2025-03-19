const { Pool } = require('pg');

const pool = new Pool({
  host: '35.203.126.72',
  user: 'dispatch-admin',
  password: 'test123!!',
  database: 'dispatch-dashboard',
  port: 5432
});

async function inspectDatabase() {
  try {
    console.log('Inspecting database schema...');
    
    // Get all tables
    const tablesResult = await pool.query(`
      SELECT table_name 
      FROM information_schema.tables 
      WHERE table_schema = 'public'
      ORDER BY table_name
    `);
    
    console.log(`\nFound ${tablesResult.rows.length} tables:\n`);
    
    // For each table, get its columns
    for (const tableRow of tablesResult.rows) {
      const tableName = tableRow.table_name;
      console.log(`\n== TABLE: ${tableName} ==`);
      
      const columnsResult = await pool.query(`
        SELECT 
          column_name, 
          data_type, 
          is_nullable, 
          column_default
        FROM 
          information_schema.columns 
        WHERE 
          table_schema = 'public' AND 
          table_name = $1
        ORDER BY 
          ordinal_position
      `, [tableName]);
      
      columnsResult.rows.forEach(col => {
        console.log(`  - ${col.column_name} (${col.data_type})${col.is_nullable === 'YES' ? ' NULL' : ' NOT NULL'}${col.column_default ? ' DEFAULT ' + col.column_default : ''}`);
      });
      
      // Get first few rows of data from each table
      try {
        const dataResult = await pool.query(`
          SELECT * FROM "${tableName}" LIMIT 3
        `);
        
        if (dataResult.rows.length > 0) {
          console.log(`\n  Sample data (${dataResult.rows.length} rows):`);
          dataResult.rows.forEach((row, i) => {
            console.log(`  Row ${i+1}:`, JSON.stringify(row, null, 2).substring(0, 150) + (JSON.stringify(row).length > 150 ? '...' : ''));
          });
        } else {
          console.log('  No data in this table');
        }
      } catch (err) {
        console.log(`  Error getting sample data: ${err.message}`);
      }
    }
    
  } catch (error) {
    console.error('Error inspecting database:', error);
  } finally {
    await pool.end();
  }
}

inspectDatabase();