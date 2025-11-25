CREATE TABLE favourites (
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    like_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, product_id),
    CONSTRAINT fk_fav_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_fav_product FOREIGN KEY (product_id) REFERENCES products(product_id)
);
