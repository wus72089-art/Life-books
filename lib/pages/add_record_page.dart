import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/repository.dart';

/// 通用记录页面 — 支持新建与编辑
/// 支持文字输入、分类选择、标签添加、图片上传
class AddRecordPage extends StatefulWidget {
  final String bookType;
  final String bookTitle;
  final Map<String, dynamic>? existingRecord;

  const AddRecordPage({
    super.key,
    required this.bookType,
    required this.bookTitle,
    this.existingRecord,
  });

  @override
  State<AddRecordPage> createState() => _AddRecordPageState();
}

class _AddRecordPageState extends State<AddRecordPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  final _picker = ImagePicker();
  String _selectedSubType = '';
  final List<String> _tags = [];
  final List<String> _imagePaths = []; // 本地图片路径
  bool _isSaving = false;
  bool _isPicking = false;

  // 各册子类型对应的子分类
  static const Map<String, List<Map<String, String>>> _subTypes = {
    'family': [
      {'value': 'diary', 'label': '家庭日记'},
      {'value': 'archive', 'label': '家庭档案'},
      {'value': 'memory', 'label': '家庭回忆'},
      {'value': 'photo_desc', 'label': '照片描述'},
    ],
    'learning': [
      {'value': 'book', 'label': '读书笔记'},
      {'value': 'knowledge', 'label': '知识库'},
      {'value': 'course', 'label': '课程学习'},
      {'value': 'skill', 'label': '技能成长'},
    ],
    'life': [
      {'value': 'daily', 'label': '日常记录'},
      {'value': 'finance', 'label': '财务记录'},
      {'value': 'travel', 'label': '旅行记录'},
      {'value': 'health', 'label': '健康记录'},
    ],
    'work': [
      {'value': 'tour_guide', 'label': '导游工作'},
      {'value': 'media', 'label': '自媒体'},
      {'value': 'ai_tool', 'label': 'AI工具'},
      {'value': 'project', 'label': '项目记录'},
    ],
    'three_views': [
      {'value': 'world', 'label': '见天地'},
      {'value': 'people', 'label': '见众生'},
      {'value': 'self', 'label': '见自己'},
    ],
  };

  List<Map<String, String>> get _currentSubTypes =>
      _subTypes[widget.bookType] ?? [];

  @override
  void initState() {
    super.initState();
    // 默认选中第一个分类
    if (_currentSubTypes.isNotEmpty) {
      _selectedSubType = _currentSubTypes[0]['value']!;
    }

    // 编辑模式：用已有数据填充
    if (widget.existingRecord != null) {
      final r = widget.existingRecord!;
      _titleController.text = (r['title'] ?? '') as String;
      _contentController.text = (r['content'] ?? '') as String;

      final savedSubType = (r['subType'] ?? '') as String;
      if (savedSubType.isNotEmpty && _currentSubTypes.any((st) => st['value'] == savedSubType)) {
        _selectedSubType = savedSubType;
      }

      final savedTags = r['tags'] as List<dynamic>?;
      if (savedTags != null) {
        _tags.addAll(savedTags.map((e) => e.toString()));
      }

      final savedImages = r['imagePaths'] as List<dynamic>?;
      if (savedImages != null) {
        _imagePaths.addAll(savedImages.map((e) => e.toString()));
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagsController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagsController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() => _tags.remove(tag));
  }

  Future<void> _pickImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('选择图片来源', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFF5C4033)),
                title: const Text('从相册选择'),
                onTap: () { Navigator.pop(ctx); _pickFromGallery(); },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF5C4033)),
                title: const Text('拍照'),
                onTap: () { Navigator.pop(ctx); _pickFromCamera(); },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFromGallery() async {
    setState(() => _isPicking = true);
    try {
      final files = await _picker.pickMultiImage(imageQuality: 80, maxWidth: 1920, maxHeight: 1920);
      if (files != null && files.isNotEmpty) {
        setState(() => _imagePaths.addAll(files.map((f) => f.path)));
      }
    } catch (e) {
      if (mounted) _showSnack('选择图片失败: $e');
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  Future<void> _pickFromCamera() async {
    setState(() => _isPicking = true);
    try {
      final file = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80, maxWidth: 1920, maxHeight: 1920);
      if (file != null) {
        setState(() => _imagePaths.add(file.path));
      }
    } catch (e) {
      if (mounted) _showSnack('拍照失败: $e');
    } finally {
      if (mounted) setState(() => _isPicking = false);
    }
  }

  void _removeImage(int index) {
    setState(() => _imagePaths.removeAt(index));
  }

  Future<void> _saveRecord() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty) {
      _showSnack('请输入标题');
      return;
    }
    if (content.isEmpty) {
      _showSnack('请输入内容');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final repo = DataRepository();
      final isEditing = widget.existingRecord != null;

      if (isEditing) {
        // 编辑模式
        final id = widget.existingRecord!['id'] as String;
        await repo.updateRecord(widget.bookType, id, {
          'title': title,
          'content': content,
          'subType': _selectedSubType,
          'tags': _tags,
          'imagePaths': _imagePaths,
          'attachments': widget.existingRecord!['attachments'] ?? [],
          'isFavorite': widget.existingRecord!['isFavorite'] ?? false,
        });

        if (mounted) {
          _showSnack('更新成功 ✓', isSuccess: true);
          Navigator.of(context).pop(true);
        }
      } else {
        // 新建模式
        await repo.addRecord(widget.bookType, {
          'title': title,
          'content': content,
          'subType': _selectedSubType,
          'tags': _tags,
          'imagePaths': _imagePaths,
          'attachments': [],
          'isFavorite': false,
        });

        if (mounted) {
          _showSnack('保存成功 ✓', isSuccess: true);
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnack('保存失败: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSnack(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess
            ? const Color(0xFF4CAF50)
            : const Color(0xFFE57373),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingRecord != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4EC),
      appBar: AppBar(
        title: Text(isEditing ? '编辑记录' : '新建${widget.bookTitle}记录'),
        actions: [
          TextButton.icon(
            onPressed: _isSaving ? null : _saveRecord,
            icon: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded),
            label: Text(_isSaving ? '保存中...' : '保存'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题输入
            _buildLabel('标题'),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: '给这条记录取个名字...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),

            // 分类选择
            _buildLabel('分类'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _currentSubTypes.map((st) {
                final isSelected = _selectedSubType == st['value'];
                return ChoiceChip(
                  label: Text(st['label']!),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedSubType = st['value']!),
                  selectedColor: const Color(0xFF5C4033),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF5C4033),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // 内容输入
            _buildLabel('内容'),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              maxLines: 8,
              decoration: InputDecoration(
                hintText: '写下你的记录...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
                alignLabelWithHint: true,
              ),
              style: const TextStyle(fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 16),

            // 图片上传
            Row(
              children: [
                _buildLabel('图片'),
                const SizedBox(width: 8),
                if (_imagePaths.isNotEmpty)
                  Text('(${_imagePaths.length})', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
            const SizedBox(height: 8),
            if (_imagePaths.isEmpty)
              GestureDetector(
                onTap: _isPicking ? null : _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.withOpacity(0.3)),
                  ),
                  child: _isPicking
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate, size: 36, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text('点击添加图片', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
                          ],
                        ),
                ),
              ),
            if (_imagePaths.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // 添加更多按钮
                  GestureDetector(
                    onTap: _isPicking ? null : _pickImage,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                      ),
                      child: _isPicking
                          ? const Center(child: CircularProgressIndicator())
                          : const Icon(Icons.add_photo_alternate, size: 28, color: Color(0xFF5C4033)),
                    ),
                  ),
                  // 已选图片缩略图
                  ..._imagePaths.asMap().entries.map((entry) {
                    return Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: FileImage(File(entry.value)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          right: -4,
                          top: -4,
                          child: GestureDetector(
                            onTap: () => _removeImage(entry.key),
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: const BoxDecoration(
                                color: Color(0xFFE57373),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ],
            const SizedBox(height: 20),

            // 标签
            _buildLabel('标签'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagsController,
                    decoration: InputDecoration(
                      hintText: '添加标签...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.add_rounded),
                        onPressed: _addTag,
                      ),
                    ),
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
              ],
            ),
            if (_tags.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _tags.map((tag) {
                  return Chip(
                    label: Text('#$tag', style: const TextStyle(fontSize: 12)),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => _removeTag(tag),
                    backgroundColor: const Color(0xFFEDE7E0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 30),

            // 保存按钮
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveRecord,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5C4033),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        isEditing ? '保存修改' : '保存记录',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Color(0xFF5C4033),
      ),
    );
  }
}
