import Foundation
import SQLiteVec

struct Item {
    let index: Int
    let vector: [Float]
    let title: String
    let content: String
}

@main
enum CLI {
    static func main() async throws {
        try SQLiteVec.initialize()
        let data = [
            Item(
                index: 1,
                vector: [0.1, 0.1, 0.1, 0.1],
                title: "Introduction to Machine Learning",
                content: "Machine learning is a subset of artificial intelligence..."
            ),
            Item(
                index: 2,
                vector: [0.2, 0.2, 0.2, 0.2],
                title: "Deep Learning Basics",
                content: "Deep learning uses neural networks to learn from data..."
            ),
            Item(
                index: 3,
                vector: [0.3, 0.3, 0.3, 0.3],
                title: "Natural Language Processing",
                content: "NLP combines linguistics and machine learning..."
            ),
            Item(
                index: 4,
                vector: [0.4, 0.4, 0.4, 0.4],
                title: "Computer Vision",
                content: "Computer vision enables machines to understand visual data..."
            ),
            Item(
                index: 5,
                vector: [0.5, 0.5, 0.5, 0.5],
                title: "Reinforcement Learning",
                content: "Reinforcement learning involves agents learning through interaction..."
            ),
        ]
        let query: [Float] = [0.3, 0.3, 0.3, 0.3]
        let textQuery = "learning"

        let db = try Database(.inMemory)
        try await db.execute("CREATE VIRTUAL TABLE vec_items USING vec0(embedding float[4])")
        try await db.execute(
            """
                CREATE VIRTUAL TABLE docs USING fts5(
                    title,
                    content,
                    tokenize='porter'
                )
            """)
        for row in data {
            try await db.execute(
                """
                    INSERT INTO vec_items(rowid, embedding)
                    VALUES (?, ?)
                """,
                params: [row.index, row.vector]
            )
            try await db.execute(
                """
                INSERT INTO docs(rowid, title, content)
                VALUES (?, ?, ?)
                """,
                params: [row.index, row.title, row.content]
            )
        }
        let result = try await db.query(
            """
                SELECT rowid, distance
                FROM vec_items
                WHERE embedding MATCH ?
                ORDER BY distance
                LIMIT 3
            """,
            params: [query]
        )
        print(result)

        let textResults = try await db.query(
            """
            SELECT rowid, title, content, rank
            FROM docs
            WHERE docs MATCH ?
            ORDER BY rank
            LIMIT 3
            """,
            params: [textQuery]
        )
        print(textResults)
    }
}
