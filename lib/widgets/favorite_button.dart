import 'package:flutter/material.dart';
import '../storage/favorites_storage.dart';

/// Nút trái tim: đọc trạng thái khi mở, bấm thì toggle. Tái dùng ở mọi nơi.
class FavoriteButton extends StatefulWidget {
  final String productId;
  const FavoriteButton({super.key, required this.productId});

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  final _store = FavoritesStorage();
  bool _isFav = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final v = await _store.isFavorite(widget.productId);
    if (mounted) setState(() => _isFav = v);
  }

  Future<void> _toggle() async {
    await _store.toggle(widget.productId);
    if (mounted) setState(() => _isFav = !_isFav);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _isFav ? Icons.favorite : Icons.favorite_border,
        color: _isFav ? Colors.red : Colors.white,
      ),
      onPressed: _toggle,
    );
  }
}
