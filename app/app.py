import os
import mysql.connector
from flask import Flask, jsonify, render_template

app = Flask(__name__)

# MySQL configuration from Docker environment variables
DB_HOST = os.getenv("DB_HOST", "10.0.2.166")
DB_PORT = int(os.getenv("DB_PORT", "3306"))
DB_NAME = os.getenv("DB_NAME", "appdb")
DB_USER = os.getenv("DB_USER", "appuser")
DB_PASSWORD = os.getenv("DB_PASSWORD", "")


def get_db_connection():
    return mysql.connector.connect(
        host=DB_HOST,
        port=DB_PORT,
        database=DB_NAME,
        user=DB_USER,
        password=DB_PASSWORD,
        connection_timeout=5,
    )


@app.route("/")
def home():
    return render_template("index.html")


@app.route("/health")
def health():
    return jsonify({
        "status": "healthy",
        "application": "Flask",
    }), 200


@app.route("/db-health")
def db_health():
    connection = None
    cursor = None

    try:
        connection = get_db_connection()
        cursor = connection.cursor()
        cursor.execute("SELECT 1")
        result = cursor.fetchone()

        return jsonify({
            "status": "connected",
            "database": DB_NAME,
            "result": result[0],
        }), 200

    except Exception:
        app.logger.exception("Database health check failed")

        return jsonify({
            "status": "database connection failed",
            "database": DB_NAME,
        }), 503

    finally:
        if cursor is not None:
            cursor.close()

        if connection is not None and connection.is_connected():
            connection.close()


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
