/// Một dòng giỏ hàng — lưu kèm SNAPSHOT sản phẩm (name/price/image) lúc thêm,
/// để CartPage vẽ được mà KHÔNG cần gọi lại backend.
/// productId là String vì dùng Mongo `_id` (không phải int như lab gốc).
class CartItem {
  final String productId;
  final String name;
  final double price;
  final String imageUrl;
  final int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.quantity,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'name': name,
        'price': price,
        'imageUrl': imageUrl,
        'quantity': quantity,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        productId: json['productId'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        imageUrl: json['imageUrl'] as String,
        quantity: json['quantity'] as int,
      );

  CartItem copyWith({int? quantity}) => CartItem(
        productId: productId,
        name: name,
        price: price,
        imageUrl: imageUrl,
        quantity: quantity ?? this.quantity,
      );
}
