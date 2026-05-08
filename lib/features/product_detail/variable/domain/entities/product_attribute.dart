/// Product attribute entity (e.g., Color, Size)
class ProductAttributeEntity {
  final String attributeName;
  final String attributeValue;
  final String? attributeSlug;

  const ProductAttributeEntity({
    required this.attributeName,
    required this.attributeValue,
    this.attributeSlug,
  });
}
