/// Word dictionary and matching algorithms for glide typing.
///
/// Contains:
/// - Top 500 common English words
/// - Word matching and scoring functions
/// - Path-to-word matching algorithm

class WordDictionary {
  /// Top 500 most common English words
  static const List<String> commonWords = [
    // Articles
    'the', 'a', 'an',
    
    // Common verbs
    'is', 'be', 'are', 'was', 'were', 'been', 'being',
    'have', 'has', 'had', 'having',
    'do', 'does', 'did', 'doing',
    'will', 'would', 'should', 'could', 'can', 'may', 'might', 'must',
    'go', 'goes', 'went', 'going',
    'get', 'gets', 'got', 'getting',
    'make', 'makes', 'made', 'making',
    'take', 'takes', 'took', 'taking',
    'come', 'comes', 'came', 'coming',
    'see', 'sees', 'saw', 'seeing',
    'know', 'knows', 'knew', 'knowing',
    'think', 'thinks', 'thought', 'thinking',
    'want', 'wants', 'wanted', 'wanting',
    'give', 'gives', 'gave', 'giving',
    'use', 'uses', 'used', 'using',
    'find', 'finds', 'found', 'finding',
    'tell', 'tells', 'told', 'telling',
    'work', 'works', 'worked', 'working',
    'call', 'calls', 'called', 'calling',
    'try', 'tries', 'tried', 'trying',
    'ask', 'asks', 'asked', 'asking',
    'need', 'needs', 'needed', 'needing',
    'feel', 'feels', 'felt', 'feeling',
    'become', 'becomes', 'became', 'becoming',
    'leave', 'leaves', 'left', 'leaving',
    'put', 'puts', 'putting',
    'mean', 'means', 'meant', 'meaning',
    'keep', 'keeps', 'kept', 'keeping',
    'let', 'lets', 'letting',
    'begin', 'begins', 'began', 'beginning',
    'seem', 'seems', 'seemed', 'seeming',
    'help', 'helps', 'helped', 'helping',
    'talk', 'talks', 'talked', 'talking',
    'turn', 'turns', 'turned', 'turning',
    'start', 'starts', 'started', 'starting',
    'show', 'shows', 'showed', 'showing',
    'hear', 'hears', 'heard', 'hearing',
    'play', 'plays', 'played', 'playing',
    'run', 'runs', 'ran', 'running',
    'move', 'moves', 'moved', 'moving',
    'like', 'likes', 'liked', 'liking',
    'live', 'lives', 'lived', 'living',
    'believe', 'believes', 'believed', 'believing',
    'hold', 'holds', 'held', 'holding',
    'bring', 'brings', 'brought', 'bringing',
    'happen', 'happens', 'happened', 'happening',
    'write', 'writes', 'wrote', 'writing',
    'provide', 'provides', 'provided', 'providing',
    'sit', 'sits', 'sat', 'sitting',
    'stand', 'stands', 'stood', 'standing',
    'lose', 'loses', 'lost', 'losing',
    'pay', 'pays', 'paid', 'paying',
    'meet', 'meets', 'met', 'meeting',
    'include', 'includes', 'included', 'including',
    'continue', 'continues', 'continued', 'continuing',
    'set', 'sets', 'setting',
    'learn', 'learns', 'learned', 'learning',
    'change', 'changes', 'changed', 'changing',
    'lead', 'leads', 'led', 'leading',
    'understand', 'understands', 'understood', 'understanding',
    'watch', 'watches', 'watched', 'watching',
    'follow', 'follows', 'followed', 'following',
    'stop', 'stops', 'stopped', 'stopping',
    'create', 'creates', 'created', 'creating',
    'speak', 'speaks', 'spoke', 'speaking',
    'read', 'reads', 'read', 'reading',
    'allow', 'allows', 'allowed', 'allowing',
    'add', 'adds', 'added', 'adding',
    'spend', 'spends', 'spent', 'spending',
    'grow', 'grows', 'grew', 'growing',
    'open', 'opens', 'opened', 'opening',
    'walk', 'walks', 'walked', 'walking',
    'win', 'wins', 'won', 'winning',
    'offer', 'offers', 'offered', 'offering',
    'remember', 'remembers', 'remembered', 'remembering',
    
    // Common nouns
    'man', 'men', 'woman', 'women', 'child', 'children', 'person', 'people',
    'day', 'days', 'time', 'times', 'year', 'years', 'week', 'weeks',
    'month', 'months', 'hour', 'hours', 'minute', 'minutes',
    'hand', 'hands', 'head', 'heart', 'eye', 'eyes', 'face', 'body',
    'life', 'work', 'money', 'number', 'part', 'water', 'place', 'world',
    'group', 'system', 'fact', 'way', 'case', 'area', 'right', 'result',
    'home', 'house', 'room', 'door', 'window', 'car', 'street', 'city',
    'country', 'government', 'school', 'student', 'teacher', 'friend',
    'family', 'parent', 'mother', 'father', 'brother', 'sister',
    'book', 'paper', 'word', 'letter', 'line', 'question', 'answer',
    'problem', 'idea', 'reason', 'interest', 'nature', 'name', 'help',
    'country', 'state', 'land', 'people', 'service', 'level', 'business',
    'company', 'market', 'price', 'value', 'cost', 'tax', 'law',
    'court', 'power', 'health', 'disease', 'medicine', 'doctor', 'hospital',
    'food', 'drink', 'meal', 'breakfast', 'lunch', 'dinner', 'table',
    'chair', 'bed', 'clothes', 'shoe', 'hat', 'coat', 'color', 'size',
    'age', 'height', 'weight', 'speed', 'distance', 'temperature',
    'event', 'game', 'sport', 'music', 'song', 'dance', 'art', 'picture',
    'movie', 'show', 'story', 'character', 'hero', 'enemy', 'adventure',
    'danger', 'fear', 'hope', 'dream', 'wish', 'memory', 'feeling',
    'love', 'hate', 'anger', 'joy', 'sadness', 'surprise', 'pain',
    'pleasure', 'success', 'failure', 'victory', 'defeat', 'progress',
    'reason', 'purpose', 'goal', 'plan', 'decision', 'choice', 'change',
    'difference', 'similarity', 'truth', 'lie', 'justice', 'peace', 'war',
    'science', 'mathematics', 'history', 'geography', 'language', 'culture',
    'religion', 'belief', 'tradition', 'custom', 'holiday', 'celebration',
    'wedding', 'birth', 'death', 'marriage', 'divorce', 'crime', 'punishment',
    'technology', 'computer', 'phone', 'internet', 'email', 'social', 'media',
    'money', 'dollar', 'pound', 'euro', 'coin', 'bank', 'debt', 'loan',
    'job', 'career', 'employment', 'boss', 'employee', 'salary', 'wage',
    'vacation', 'travel', 'journey', 'trip', 'flight', 'hotel', 'tour',
    'animal', 'dog', 'cat', 'bird', 'fish', 'snake', 'lion', 'tiger',
    'nature', 'tree', 'flower', 'grass', 'mountain', 'river', 'ocean',
    'weather', 'rain', 'snow', 'wind', 'cloud', 'sun', 'moon', 'star',
    'fire', 'ice', 'rock', 'sand', 'soil', 'air', 'light', 'darkness',
    'sound', 'noise', 'silence', 'voice', 'language', 'word', 'sentence',
    
    // Adjectives
    'good', 'bad', 'big', 'small', 'long', 'short', 'tall', 'high', 'low',
    'new', 'old', 'young', 'strong', 'weak', 'fast', 'slow', 'hot', 'cold',
    'wet', 'dry', 'clean', 'dirty', 'bright', 'dark', 'light', 'heavy',
    'soft', 'hard', 'rough', 'smooth', 'thick', 'thin', 'wide', 'narrow',
    'deep', 'shallow', 'far', 'near', 'late', 'early', 'quick', 'slow',
    'loud', 'quiet', 'sweet', 'bitter', 'sour', 'salty', 'beautiful',
    'ugly', 'pretty', 'handsome', 'ugly', 'rich', 'poor', 'happy', 'sad',
    'angry', 'calm', 'nervous', 'brave', 'shy', 'rude', 'polite', 'kind',
    'cruel', 'honest', 'dishonest', 'smart', 'stupid', 'wise', 'foolish',
    'careful', 'careless', 'serious', 'funny', 'silly', 'boring', 'exciting',
    'interesting', 'curious', 'lazy', 'busy', 'full', 'empty', 'possible',
    'impossible', 'easy', 'difficult', 'hard', 'simple', 'complex',
    'clear', 'confused', 'confused', 'certain', 'uncertain', 'sure',
    'uncertain', 'familiar', 'strange', 'common', 'rare', 'special',
    'ordinary', 'wonderful', 'terrible', 'amazing', 'awful', 'excellent',
    'perfect', 'imperfect', 'better', 'worse', 'best', 'worst', 'more',
    'less', 'most', 'least', 'equal', 'similar', 'different', 'same',
    
    // Adverbs
    'very', 'really', 'quite', 'not', 'no', 'yes', 'maybe', 'probably',
    'certainly', 'definitely', 'never', 'ever', 'always', 'often', 'sometimes',
    'rarely', 'usually', 'just', 'only', 'still', 'already', 'yet', 'today',
    'tomorrow', 'yesterday', 'tonight', 'now', 'here', 'there', 'where',
    'when', 'why', 'how', 'what', 'which', 'who', 'whom', 'whose',
    'above', 'below', 'between', 'under', 'over', 'around', 'about',
    'through', 'across', 'along', 'after', 'before', 'during', 'while',
    'until', 'since', 'because', 'although', 'unless', 'if', 'then',
    'else', 'otherwise', 'but', 'however', 'therefore', 'thus',
    
    // Pronouns
    'i', 'me', 'you', 'he', 'him', 'she', 'her', 'it', 'we', 'us',
    'they', 'them', 'this', 'that', 'these', 'those', 'myself', 'yourself',
    'himself', 'herself', 'itself', 'ourselves', 'yourselves', 'themselves',
    'mine', 'yours', 'his', 'hers', 'ours', 'theirs', 'my', 'your',
    'our', 'their', 'someone', 'anyone', 'nobody', 'everybody',
    'something', 'anything', 'nothing', 'everything',
    
    // Prepositions & Conjunctions
    'in', 'on', 'at', 'to', 'from', 'with', 'for', 'by', 'of', 'and',
    'or', 'as', 'so', 'if', 'than', 'that', 'up', 'out', 'into', 'like',
    'down', 'off', 'against', 'without', 'among', 'between', 'through',
    'during', 'before', 'after', 'above', 'below', 'near', 'beside',
    
    // Additional common words
    'hello', 'hi', 'hey', 'okay', 'ok', 'yes', 'no', 'thanks', 'thank',
    'please', 'sorry', 'excuse', 'help', 'thanks', 'welcome', 'goodbye',
    'bye', 'see', 'talk', 'later', 'soon', 'right', 'left', 'good', 'bad',
    'better', 'best', 'worse', 'worst', 'much', 'many', 'some', 'all',
    'each', 'every', 'either', 'neither', 'both', 'once', 'twice',
    'three', 'four', 'five', 'six', 'seven', 'eight', 'nine', 'ten',
    'first', 'second', 'third', 'last', 'next', 'other', 'another',
  ];

  /// Calculate the similarity score between a path and a word
  ///
  /// Uses a combination of:
  /// - Letter sequence presence in order
  /// - Edit distance (Levenshtein)
  /// - Character positions
  static double calculatePathScore(String path, String word) {
    // Normalize inputs
    path = path.toLowerCase().trim();
    word = word.toLowerCase().trim();

    if (path.isEmpty || word.isEmpty) return 0.0;
    if (path == word) return 100.0;

    // Score based on letter sequence match
    double sequenceScore = _calculateSequenceScore(path, word);

    // Score based on edit distance
    double editDistanceScore = _calculateEditDistanceScore(path, word);

    // Score based on length similarity
    double lengthScore = _calculateLengthScore(path, word);

    // Weighted combination
    final totalScore =
        (sequenceScore * 0.5) + (editDistanceScore * 0.3) + (lengthScore * 0.2);

    return totalScore;
  }

  /// Calculate score based on sequence matching
  /// How many consecutive letters from path appear in word in order
  static double _calculateSequenceScore(String path, String word) {
    int matchedLength = 0;
    int wordIndex = 0;

    for (int i = 0; i < path.length && wordIndex < word.length; i++) {
      if (path[i] == word[wordIndex]) {
        matchedLength++;
        wordIndex++;
      }
    }

    // Return percentage of matched characters
    return (matchedLength / word.length) * 100.0;
  }

  /// Calculate score based on edit distance (Levenshtein distance)
  static double _calculateEditDistanceScore(String path, String word) {
    final distance = _levenshteinDistance(path, word);
    final maxDistance = (path.length + word.length) / 2;

    if (maxDistance == 0) return 100.0;

    return ((maxDistance - distance) / maxDistance) * 100.0;
  }

  /// Calculate Levenshtein distance between two strings
  static int _levenshteinDistance(String a, String b) {
    a = a.toLowerCase();
    b = b.toLowerCase();

    final matrix = List<List<int>>.generate(
      a.length + 1,
      (_) => List<int>.filled(b.length + 1, 0),
    );

    // Initialize first row and column
    for (int i = 0; i <= a.length; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= b.length; j++) {
      matrix[0][j] = j;
    }

    // Calculate distances
    for (int i = 1; i <= a.length; i++) {
      for (int j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,      // deletion
          matrix[i][j - 1] + 1,      // insertion
          matrix[i - 1][j - 1] + cost, // substitution
        ].reduce((a, b) => a < b ? a : b);
      }
    }

    return matrix[a.length][b.length];
  }

  /// Calculate score based on length similarity
  static double _calculateLengthScore(String path, String word) {
    final lengthDiff = (path.length - word.length).abs();
    final maxLength = [path.length, word.length].reduce((a, b) => a > b ? a : b);

    if (maxLength == 0) return 100.0;

    return ((maxLength - lengthDiff) / maxLength) * 100.0;
  }

  /// Find best matching words from dictionary
  ///
  /// Returns list of words scored and sorted by match quality
  static List<MapEntry<String, double>> findMatchingWords(
    String path, {
    int limit = 3,
    double minScore = 30.0,
  }) {
    if (path.isEmpty) return [];

    // Calculate scores for all words
    final scores = commonWords.map((word) {
      return MapEntry(word, calculatePathScore(path, word));
    }).toList();

    // Filter by minimum score and sort by score (descending)
    final filtered = scores
        .where((entry) => entry.value >= minScore)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Return top results
    return filtered.take(limit).toList();
  }

  /// Check if a word exists in the dictionary
  static bool contains(String word) {
    return commonWords.contains(word.toLowerCase());
  }

  /// Get all words starting with a prefix
  static List<String> getWordsWithPrefix(String prefix) {
    return commonWords
        .where((word) => word.startsWith(prefix.toLowerCase()))
        .toList();
  }

  /// Get word suggestions for autocorrect
  static List<String> getSuggestions(String word, {int limit = 3}) {
    if (word.isEmpty) return [];

    final matches = findMatchingWords(word, limit: limit, minScore: 20.0);
    return matches.map((entry) => entry.key).toList();
  }
}
