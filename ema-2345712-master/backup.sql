INSERT INTO `product_variation_order` (`order_id`, `product_variation_id`, `quantity`, `created_at`, `updated_at`)
VALUES
	(77, 68, 1, '2020-09-01 15:47:46', '2020-09-01 15:47:46'),
	(77, 124, 1, '2020-09-01 15:47:46', '2020-09-01 15:47:46'),
	(77, 228, 1, '2020-09-01 15:47:46', '2020-09-01 15:47:46'),
	(77, 130, 1, '2020-09-01 15:47:46', '2020-09-01 15:47:46'),
	(78, 68, 1, '2020-09-01 17:35:56', '2020-09-01 17:35:56');


INSERT INTO `orders` (`id`, `user_id`, `created_at`, `updated_at`, `address_id`, `shipping_method_id`, `status`, `subtotal`, `payment_method_id`, `uuid`, `currency`)
VALUES
	(77, 144, '2020-09-01 15:47:46', '2020-09-01 19:50:22', 52, 2, 'Completed', '10.25', 1, 'EOT000077', 'USD'),
	(78, 144, '2020-09-01 17:35:56', '2020-09-01 19:50:10', 52, 2, 'Pending', '0.85', 1, 'EOT000078', 'USD');