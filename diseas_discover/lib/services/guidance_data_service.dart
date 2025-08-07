// lib/services/guidance_data_service.dart
// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

class GuidanceDataService {
  static Map<String, dynamic> getGuidanceForClass(String? className) {
    if (className == null) {
      print("GuidanceDataService: className is null, returning default.");
      return {
        'initial_greeting': "يرجى إجراء تحليل أولاً لعرض الإرشادات.",
        'questions': [],
      };
    }

    print("GuidanceDataService: Received className for guidance: '$className'");

    String lowerClassName = className.toLowerCase();
    Map<String, dynamic> baseContent = {
      'initial_greeting':
          "مرحباً! بناءً على نتيجة التحليل لـ '\u202B$className\u202C'، يمكنني تقديم بعض المعلومات الأولية. تذكر، هذه ليست استشارة طبية.",
      'questions': [],
    };

    if (lowerClassName.contains('bcc')) {
      print("GuidanceDataService: Matched 'bcc'");
      baseContent['questions'] = [
        {
          'id': 'bcc_what_is',
          'question': "ما هو سرطان الخلايا القاعدية؟",
          'answer':
              "سرطان الخلايا القاعدية هو أكثر أنواع سرطان الجلد شيوعًا. ينمو ببطء وعادة ما يكون قابلاً للعلاج، خاصة عند اكتشافه مبكرًا.",
          'next_questions': [
            {
              'id': 'bcc_is_dangerous',
              'question': "هل هو خطير؟",
              'answer':
                  "بينما يعتبر أقل خطورة من الميلانوما ونادرًا ما ينتشر، إلا أنه يحتاج إلى علاج لمنع نموه وإلحاق الضرر بالأنسجة المحيطة. استشر طبيبك."
            },
          ]
        },
        {
          'id': 'bcc_prevention',
          'question': "ما هي نصائح الوقاية؟",
          'answer':
              "تجنب التعرض المفرط للشمس، استخدم واقي الشمس، وافحص جلدك بانتظام."
        },
      ];
    } else if (lowerClassName.contains('mel')) {
      print("GuidanceDataService: Matched 'mel'");
      baseContent['questions'] = [
        {
          'id': 'mel_what_is',
          'question': "ما هو سرطان الجلد (الميلانوما)؟",
          'answer':
              "الميلانوما هو نوع خطير من سرطان الجلد يبدأ في الخلايا الصباغية المنتجة للصبغة. من المهم جدًا رؤية طبيب جلدية للتقيیم.",
          'next_questions': [
            {
              'id': 'mel_what_to_do',
              'question': "ماذا يجب أن أفعل الآن؟",
              'answer':
                  "الخطوة الأكثر أهمية هي حجز موعد مع طبيب جلدية في أقرب وقت ممكن. سيقوم الطبيب بإجراء فحص شامل وقد يأخذ خزعة إذا لزم الأمر. التشخيص والعلاج المبكر ضروريان."
            },
            {
              'id': 'mel_how_to_protect',
              'question': "كيف يمكنني حماية بشرتي؟",
              'answer':
                  "احمِ بشرتك من أشعة الشمس بارتداء واقي الشمس (SPF 30+) وملابس واقية. تجنب أسرة التسمير وقم بفحص جلدك بانتظام."
            },
          ],
          'learn_more_link':
              "https://www.cancer.org/cancer/types/melanoma-skin-cancer.html",
          'learn_more_text': "المزيد عن الميلانوما (موقع خارجي)"
        },
        {
          'id': 'mel_is_treatable',
          'question': "هل هو قابل للعلاج؟",
          'answer':
              "عند اكتشافها مبكرًا، تكون الميلانوما قابلة للعلاج بشكل كبير. طبيبك هو أفضل من يناقش معك خيارات العلاج بناءً على حالتك."
        },
      ];
    } else if (lowerClassName.contains('nv')) {
      print("GuidanceDataService: Matched 'nv'");
      baseContent['initial_greeting'] =
          "النتيجة تشير إلى شامة (وحمة ميلانينية).";
      baseContent['questions'] = [
        {
          'id': 'nevi_is_dangerous',
          'question': "هل الشامات خطيرة؟",
          'answer':
              "معظم الشامات غير ضارة (حميدة). ومع ذلك، من المهم مراقبتها بحثًا عن أي تغييرات (ABCDEs: Asymmetry, Border, Color, Diameter, Evolving).",
          'next_questions': [
            {
              'id': 'nevi_when_to_worry',
              'question': "متى يجب أن أقلق بشأن شامة؟",
              'answer':
                  "إذا لاحظت أي تغييرات في الحجم، الشكل، اللون، أو إذا بدأت شامة في الحكة، النزيف، أو أصبحت مؤلمة، فاستشر طبيب جلدية."
            },
          ]
        },
      ];
    } else {
      print("GuidanceDataService: Matched 'other' for className: '$className'");
      baseContent['questions'] = [
        {
          'id': 'other_what_is',
          'question': "ماذا تعني هذه النتيجة؟",
          'answer':
              "النتيجة تشير إلى '\u202B$className\u202C'. للحصول على فهم كامل، من الأفضل استشارة طبيب جلدية."
        },
        {
          'id': 'other_next_steps',
          'question': "هل هناك خطوات تالية مقترحة؟",
          'answer':
              "نعم، الخطوة التالية الموصى بها هي مناقشة هذه النتيجة مع طبيب مختص. يمكنهم تقديم تقييم دقيق وإرشادات شخصية."
        },
      ];
    }
    print(
        "GuidanceDataService: Returning ${baseContent['questions'].length} questions for $className");
    return baseContent;
  }
}
