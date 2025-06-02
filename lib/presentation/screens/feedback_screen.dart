import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';

import 'package:zifromania/domain/entities/constant.dart';
import 'package:zifromania/presentation/common/back_button.dart';
import 'package:zifromania/presentation/widgets/animated_icon_button.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  File? _selectedImage;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      _showSnackBar(
        tr('feedback.pick_image_error', args: [e.toString()]),
        isError: true,
      );
    }
  }

  Future<void> _removeImage() async {
    setState(() {
      _selectedImage = null;
    });
  }

  Future<void> _sendFeedback() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final email = dotenv.env['GMAIL_USER'];
      final password = dotenv.env['GMAIL_PASS'];
      final smtpServer = gmail(email!, password!);

      final message = Message()
        ..from = Address(
          _emailController.text.trim(),
          _nameController.text.trim(),
        )
        ..recipients.add('rasul.ramixanov@gmail.com')
        ..subject = tr(
          'feedback.email_subject',
          args: [_subjectController.text.trim()],
        )
        ..html = _buildEmailHtml();

      // Attach image if selected
      if (_selectedImage != null) {
        final attachment = FileAttachment(
          _selectedImage!,
          fileName: 'feedback_image_${DateTime.now().millisecondsSinceEpoch}.jpg',
        );
        message.attachments.add(attachment);
      }

      await send(message, smtpServer);
      _showSnackBar(tr('feedback.feedback_sent'));
      _clearForm();
    } catch (e) {
      log(e.toString());
      _showSnackBar(tr('feedback.feedback_error', args: [e.toString()]), isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _buildEmailHtml() {
    return '''
    <html>
      <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
        <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
          <h2 style="color: #2c3e50; border-bottom: 2px solid #3498db; padding-bottom: 10px;">
            ${tr('feedback.email_html_title')}
          </h2>
          
          <div style="background-color: #f8f9fa; padding: 15px; border-radius: 8px; margin: 20px 0;">
            <h3 style="color: #495057; margin-top: 0;">${tr('feedback.email_html_contact')}</h3>
            <p><strong>${tr('feedback.email_html_name')}</strong> ${_nameController.text.trim()}</p>
            <p><strong>${tr('feedback.email_html_email')}</strong> ${_emailController.text.trim()}</p>
            <p><strong>${tr('feedback.email_html_subject')}</strong> ${_subjectController.text.trim()}</p>
          </div>
          
          <div style="background-color: #ffffff; padding: 15px; border-left: 4px solid #3498db; margin: 20px 0;">
            <h3 style="color: #495057; margin-top: 0;">${tr('feedback.email_html_message')}</h3>
            <p style="white-space: pre-line;">${_messageController.text.trim()}</p>
          </div>
          
          <div style="margin-top: 30px; padding-top: 15px; border-top: 1px solid #dee2e6; color: #6c757d; font-size: 12px;">
            <p>${tr('feedback.email_html_footer', args: [DateTime.now().toString()])}</p>
          </div>
        </div>
      </body>
    </html>
    ''';
  }

  void _clearForm() {
    _nameController.clear();
    _emailController.clear();
    _subjectController.clear();
    _messageController.clear();
    setState(() => _selectedImage = null);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade400,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: CustomBackButton(color: lightBrownColor),
        elevation: 0,
        title: Text(
          tr('feedback.title'),
          style: TextStyle(fontFamily: 'Scabber', fontSize: 22, color: lightBrownColor),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            colorFilter: ColorFilter.mode(
              Colors.black45,
              BlendMode.darken,
            ),
            image: AssetImage('assets/images/scaffold.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.withOpacity(.3),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Image.asset(
                              'assets/icons/feedback.png',
                              opacity: AlwaysStoppedAnimation(0.7),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            tr('feedback.header_title'),
                            style: TextStyle(
                              fontSize: 24,
                              fontFamily: 'Scabber',
                              fontWeight: FontWeight.bold,
                              color: Colors.blueGrey.shade200.withOpacity(.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            tr('feedback.header_subtitle'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: 'Scabber',
                              color: Colors.blueGrey.shade300.withOpacity(.7),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Form Fields
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.withOpacity(.3),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name Field
                          _buildLabel(tr('feedback.name_label')),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _nameController,
                            hintText: tr('feedback.name_hint'),
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return tr('feedback.name_error');
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Email Field
                          _buildLabel(tr('feedback.email_label')),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _emailController,
                            hintText: tr('feedback.email_hint'),
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return tr('feedback.email_error_empty');
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                return tr('feedback.email_error_invalid');
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Subject Field
                          _buildLabel(tr('feedback.subject_label')),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _subjectController,
                            hintText: tr('feedback.subject_hint'),
                            icon: Icons.subject_outlined,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return tr('feedback.subject_error');
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Message Field
                          _buildLabel(tr('feedback.message_label')),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _messageController,
                            hintText: tr('feedback.message_hint'),
                            maxLines: 5,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return tr('feedback.message_error_empty');
                              }
                              if (value.trim().length < 10) {
                                return tr('feedback.message_error_short');
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 24),

                          // Image Section
                          _buildLabel(tr('feedback.image_label')),
                          const SizedBox(height: 12),

                          if (_selectedImage != null)
                            Container(
                              width: double.infinity,
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      _selectedImage!,
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: IconButton(
                                        onPressed: _removeImage,
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade200.withOpacity(.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.white38,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 8),
                                    Image.asset(
                                      'assets/icons/camera.png',
                                      height: 48,
                                      width: 48,
                                      opacity: const AlwaysStoppedAnimation(0.7),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      tr('feedback.image_add'),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF407093),
                                        fontFamily: 'Scabber',
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      tr('feedback.image_sub'),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white38,
                                        fontFamily: 'Scabber',
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Send Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: PressableFilledButton(
                        onPressed: () => _isLoading ? null : _sendFeedback(),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: softBlueColor.withOpacity(.7),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.send, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    tr('feedback.send'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontFamily: 'Scabber',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Footer
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100.withOpacity(.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/icons/information.png',
                            height: 24,
                            width: 24,
                            opacity: AlwaysStoppedAnimation(0.7),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              tr('feedback.footer_text'),
                              style: const TextStyle(
                                fontFamily: 'Scabber',
                                color: Colors.white38,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontFamily: 'Scabber',
        fontWeight: FontWeight.w600,
        color: Colors.white38,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    IconData? icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(
        fontSize: 14,
        fontFamily: 'Scabber',
        color: Colors.white38,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white38, fontFamily: 'Scabber'),
        errorStyle: const TextStyle(color: Colors.red, fontFamily: 'Scabber', fontSize: 12),
        prefixIcon: icon != null ? Icon(icon, color: Colors.white38, size: 20) : null,
        filled: true,
        fillColor: Colors.blueGrey.shade200.withOpacity(.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white38),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}
