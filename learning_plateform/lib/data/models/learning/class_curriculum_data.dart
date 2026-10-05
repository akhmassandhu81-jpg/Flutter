class ClassCurriculumData {
  ClassCurriculumData._();

  static Map<String, dynamic> getCurriculum(String classLevel) {
    switch (classLevel) {
      case 'class7':
        return _class7Curriculum();
      case 'class8':
        return _class8Curriculum();
      case 'class9':
        return _class9Curriculum();
      case 'class10':
        return _class10Curriculum();
      case 'class11':
        return _class11Curriculum();
      case 'class12':
        return _class12Curriculum();
      case 'class6':
      default:
        return _class6Curriculum();
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // CLASS 6 (Reference)
  // ──────────────────────────────────────────────────────────────────────────
  static Map<String, dynamic> _class6Curriculum() => {
        'id': 'computer_science',
        'title': 'Computer Science',
        'classLevel': 'class6',
        'description': 'Foundations of computing, algorithm design, digital literacy, and problem solving.',
        'chapters': {
          'ch1_intro_to_computers': {
            'id': 'ch1_intro_to_computers',
            'title': 'Chapter 1: Introduction to Computers',
            'description': 'Learn what computers are, hardware vs software, and basic components.',
            'order': 1,
            'topics': {
              'top1_what_is_computer': {
                'id': 'top1_what_is_computer',
                'title': '1.1 What is a Computer?',
                'description': 'Understanding input, processing, output, and storage.',
                'order': 1,
                'explanation': {
                  'title': 'Understanding the Computing Cycle',
                  'content': 'A computer is an electronic device that accepts raw data (input), processes it according to instructions, produces useful information (output), and stores the results for future use.\n\n### 1. Input Stage\nRaw data entered using devices like keyboard or mouse.\n\n### 2. Processing Stage\nThe CPU performs calculations and logical operations.\n\n### 3. Output Stage\nProcessed information displayed on monitor or printed.\n\n### 4. Storage Stage\nData saved in RAM or SSD for retention.'
                },
                'visualization': {
                  'type': 'flowchart',
                  'title': 'The Information Processing Cycle',
                  'steps': [
                    'Input (Keyboard, Mouse)',
                    'Processing (CPU, RAM)',
                    'Output (Monitor, Printer)',
                    'Storage (SSD, Hard Drive)'
                  ]
                },
                'activity': {
                  'type': 'algorithm_ordering',
                  'title': 'Algorithm Ordering: Processing Cycle',
                  'instruction': 'Arrange the 4 steps of the computer processing cycle in the correct chronological order.',
                  'initialItems': [
                    'Display output on screen',
                    'Enter data using keyboard',
                    'Save result to storage',
                    'CPU calculates data'
                  ],
                  'correctOrder': [
                    'Enter data using keyboard',
                    'CPU calculates data',
                    'Display output on screen',
                    'Save result to storage'
                  ]
                },
                'practiceQuestions': [
                  {
                    'id': 'p1',
                    'question': 'Which component is considered the "brain" of the computer?',
                    'options': ['Monitor', 'CPU', 'Keyboard', 'Hard Drive'],
                    'correctIndex': 1,
                    'explanation': 'The CPU (Central Processing Unit) performs all data processing.'
                  }
                ],
                'assessmentQuestions': [
                  {
                    'id': 'q1',
                    'question': 'Raw facts and figures entered into a computer are called:',
                    'options': ['Information', 'Data', 'Output', 'Software'],
                    'correctIndex': 1,
                    'explanation': 'Data refers to unprocessed raw facts.'
                  }
                ]
              }
            }
          }
        }
      };

  // ──────────────────────────────────────────────────────────────────────────
  // CLASS 7
  // ──────────────────────────────────────────────────────────────────────────
  static Map<String, dynamic> _class7Curriculum() => {
        'id': 'computer_science',
        'title': 'Computer Science',
        'classLevel': 'class7',
        'description': 'Beginner/intermediate concepts in OS file management, programming logic, and internet safety.',
        'chapters': {
          'ch1_os_files': {
            'id': 'ch1_os_files',
            'title': 'Chapter 1: Operating Systems & File Management',
            'description': 'Mastering file hierarchies, extensions, and OS utilities.',
            'order': 1,
            'topics': {
              'top1_os_overview': {
                'id': 'top1_os_overview',
                'title': '1.1 Role of an Operating System',
                'description': 'How an OS acts as an intermediary between user hardware and software.',
                'order': 1,
                'explanation': {
                  'title': 'Operating System Fundamentals',
                  'content': 'An Operating System (OS) is system software that manages computer hardware, software resources, and provides common services for computer programs.\n\n### Key Functions\n1. **Process Management**: Allocates CPU time.\n2. **Memory Management**: Controls RAM allocation.\n3. **File Management**: Organizes files in directory trees.'
                },
                'visualization': {
                  'type': 'diagram',
                  'title': 'OS Layer Architecture',
                  'steps': ['Applications', 'Operating System', 'Hardware']
                },
                'activity': {
                  'type': 'algorithm_ordering',
                  'title': 'OS Boot Sequence',
                  'instruction': 'Order the steps when turning on a computer.',
                  'initialItems': [
                    'OS loads into RAM',
                    'BIOS runs POST checks',
                    'Power button pressed',
                    'Desktop interface appears'
                  ],
                  'correctOrder': [
                    'Power button pressed',
                    'BIOS runs POST checks',
                    'OS loads into RAM',
                    'Desktop interface appears'
                  ]
                },
                'practiceQuestions': [
                  {
                    'id': 'p1',
                    'question': 'What does POST stand for in BIOS startup?',
                    'options': ['Power On Self Test', 'Program Operating System Tool', 'Primary Output Storage Task', 'Pre-Operating System Trigger'],
                    'correctIndex': 0,
                    'explanation': 'POST verifies hardware integrity during boot.'
                  }
                ],
                'assessmentQuestions': [
                  {
                    'id': 'q1',
                    'question': 'Which of the following is an Operating System?',
                    'options': ['Microsoft Word', 'Linux', 'Google Chrome', 'Python'],
                    'correctIndex': 1,
                    'explanation': 'Linux is a full-featured operating system kernel.'
                  }
                ]
              }
            }
          },
          'ch2_intro_programming': {
            'id': 'ch2_intro_programming',
            'title': 'Chapter 2: Introduction to Programming',
            'description': 'Variables, data types, and conditional logic.',
            'order': 2,
            'topics': {
              'top1_variables': {
                'id': 'top1_variables',
                'title': '2.1 Variables and Data Types',
                'description': 'Storing values in memory using named containers.',
                'order': 1,
                'explanation': {
                  'title': 'Working with Variables',
                  'content': 'A variable is a named storage location in computer memory that holds data during program execution.\n\n### Common Data Types\n- **Integer**: Whole numbers (e.g., `10`).\n- **String**: Text characters (e.g., `"Hello"`).\n- **Boolean**: True or False values.'
                },
                'visualization': {
                  'type': 'steps',
                  'title': 'Variable Assignment Steps',
                  'steps': ['Declare Variable Name', 'Assign Value with =', 'Retrieve Value in Code']
                },
                'activity': {
                  'type': 'algorithm_ordering',
                  'title': 'Variable Calculation Flow',
                  'instruction': 'Order the steps to add two integer variables.',
                  'initialItems': [
                    'Print sum result',
                    'Declare x = 5 and y = 10',
                    'Compute total = x + y',
                    'Start program'
                  ],
                  'correctOrder': [
                    'Start program',
                    'Declare x = 5 and y = 10',
                    'Compute total = x + y',
                    'Print sum result'
                  ]
                },
                'practiceQuestions': [
                  {
                    'id': 'p1',
                    'question': 'Which data type represents true or false values?',
                    'options': ['Integer', 'Boolean', 'String', 'Float'],
                    'correctIndex': 1,
                    'explanation': 'Booleans represent binary true/false conditions.'
                  }
                ],
                'assessmentQuestions': [
                  {
                    'id': 'q1',
                    'question': 'What will `x = 7` store if 7 is a whole number?',
                    'options': ['Integer', 'String', 'Boolean', 'Array'],
                    'correctIndex': 0,
                    'explanation': 'Whole numbers are stored as integer data types.'
                  }
                ]
              }
            }
          }
        }
      };

  // ──────────────────────────────────────────────────────────────────────────
  // CLASS 8
  // ──────────────────────────────────────────────────────────────────────────
  static Map<String, dynamic> _class8Curriculum() => {
        'id': 'computer_science',
        'title': 'Computer Science',
        'classLevel': 'class8',
        'description': 'Advanced programming constructs, nested loops, arrays, and cybersecurity fundamentals.',
        'chapters': {
          'ch1_prog_fundamentals': {
            'id': 'ch1_prog_fundamentals',
            'title': 'Chapter 1: Programming Fundamentals & Arrays',
            'description': 'Data structures, arrays, and iteration techniques.',
            'order': 1,
            'topics': {
              'top1_arrays': {
                'id': 'top1_arrays',
                'title': '1.1 Introduction to Arrays / Lists',
                'description': 'Storing multiple values in a single ordered collection.',
                'order': 1,
                'explanation': {
                  'title': 'Working with Arrays',
                  'content': 'An array is a data structure that stores a collection of items at contiguous memory locations.\n\n### Indexing\nElements in arrays are accessed using zero-based indices (e.g., `scores[0]` is the first item).'
                },
                'visualization': {
                  'type': 'flowchart',
                  'title': 'Array Index Layout',
                  'steps': ['Index 0: Value A', 'Index 1: Value B', 'Index 2: Value C']
                },
                'activity': {
                  'type': 'algorithm_ordering',
                  'title': 'Array Traversal Sequence',
                  'instruction': 'Order the steps to iterate through an array.',
                  'initialItems': [
                    'Access element at index i',
                    'Initialize index i = 0',
                    'Increment i until end of array',
                    'Process element data'
                  ],
                  'correctOrder': [
                    'Initialize index i = 0',
                    'Access element at index i',
                    'Process element data',
                    'Increment i until end of array'
                  ]
                },
                'practiceQuestions': [
                  {
                    'id': 'p1',
                    'question': 'What is the index of the first element in standard arrays?',
                    'options': ['1', '0', '-1', 'Any number'],
                    'correctIndex': 1,
                    'explanation': 'Standard arrays use zero-based indexing.'
                  }
                ],
                'assessmentQuestions': [
                  {
                    'id': 'q1',
                    'question': 'Which data structure holds multiple items in sequential order?',
                    'options': ['Boolean', 'Array', 'Integer', 'Operator'],
                    'correctIndex': 1,
                    'explanation': 'Arrays are ordered collections of items.'
                  }
                ]
              }
            }
          }
        }
      };

  // ──────────────────────────────────────────────────────────────────────────
  // CLASS 9
  // ──────────────────────────────────────────────────────────────────────────
  static Map<String, dynamic> _class9Curriculum() => {
        'id': 'computer_science',
        'title': 'Computer Science',
        'classLevel': 'class9',
        'description': 'Structured programming, searching/sorting algorithms, and SQL database fundamentals.',
        'chapters': {
          'ch1_algorithms_sorting': {
            'id': 'ch1_algorithms_sorting',
            'title': 'Chapter 1: Searching and Sorting Algorithms',
            'description': 'Linear search, binary search, and bubble sort.',
            'order': 1,
            'topics': {
              'top1_binary_search': {
                'id': 'top1_binary_search',
                'title': '1.1 Binary Search Algorithm',
                'description': 'Efficiently finding items in sorted datasets.',
                'order': 1,
                'explanation': {
                  'title': 'Binary Search Mechanics',
                  'content': 'Binary search is a logarithmic search algorithm that finds the position of a target value within a sorted array.\n\n### Algorithm Steps\n1. Compare target with the middle element.\n2. If equal, return index.\n3. If target is smaller, repeat on left half; else right half.'
                },
                'visualization': {
                  'type': 'steps',
                  'title': 'Binary Search Division',
                  'steps': ['Check Middle Element', 'Eliminate Half', 'Repeat Until Found']
                },
                'activity': {
                  'type': 'algorithm_ordering',
                  'title': 'Binary Search Execution',
                  'instruction': 'Order the binary search steps on a sorted list.',
                  'initialItems': [
                    'Compare target with mid',
                    'Calculate mid index',
                    'Adjust low or high pointer',
                    'Find array bounds low and high'
                  ],
                  'correctOrder': [
                    'Find array bounds low and high',
                    'Calculate mid index',
                    'Compare target with mid',
                    'Adjust low or high pointer'
                  ]
                },
                'practiceQuestions': [
                  {
                    'id': 'p1',
                    'question': 'What is the prerequisite for binary search?',
                    'options': ['List must be sorted', 'List must be strings', 'List must be empty', 'List must be reversed'],
                    'correctIndex': 0,
                    'explanation': 'Binary search requires sorted datasets to eliminate halves.'
                  }
                ],
                'assessmentQuestions': [
                  {
                    'id': 'q1',
                    'question': 'What is the time complexity of binary search?',
                    'options': ['O(n)', 'O(log n)', 'O(n^2)', 'O(1)'],
                    'correctIndex': 1,
                    'explanation': 'Binary search halves the search space each step: O(log n).'
                  }
                ]
              }
            }
          }
        }
      };

  // ──────────────────────────────────────────────────────────────────────────
  // CLASS 10
  // ──────────────────────────────────────────────────────────────────────────
  static Map<String, dynamic> _class10Curriculum() => {
        'id': 'computer_science',
        'title': 'Computer Science',
        'classLevel': 'class10',
        'description': 'Object-Oriented Programming (OOP), database design, and SQL queries.',
        'chapters': {
          'ch1_oop_concepts': {
            'id': 'ch1_oop_concepts',
            'title': 'Chapter 1: Object-Oriented Programming (OOP)',
            'description': 'Classes, objects, encapsulation, and inheritance.',
            'order': 1,
            'topics': {
              'top1_pillars_oop': {
                'id': 'top1_pillars_oop',
                'title': '1.1 Four Pillars of OOP',
                'description': 'Encapsulation, Inheritance, Polymorphism, and Abstraction.',
                'order': 1,
                'explanation': {
                  'title': 'Core Principles of Object-Oriented Design',
                  'content': 'Object-Oriented Programming models real-world entities using classes and objects.\n\n### The Four Pillars\n1. **Encapsulation**: Bundling data and methods inside a class.\n2. **Inheritance**: Reusing properties from parent classes.\n3. **Polymorphism**: Single interface for multiple data types.\n4. **Abstraction**: Hiding complex implementation details.'
                },
                'visualization': {
                  'type': 'diagram',
                  'title': 'OOP Inheritance Hierarchy',
                  'steps': ['Parent Class (Animal)', 'Child Class (Dog)', 'Object Instance (Rex)']
                },
                'activity': {
                  'type': 'algorithm_ordering',
                  'title': 'Object Instantiation Flow',
                  'instruction': 'Order the steps of creating and using an object.',
                  'initialItems': [
                    'Call object method',
                    'Define class blueprint',
                    'Allocate memory with constructor',
                    'Reference object variable'
                  ],
                  'correctOrder': [
                    'Define class blueprint',
                    'Allocate memory with constructor',
                    'Reference object variable',
                    'Call object method'
                  ]
                },
                'practiceQuestions': [
                  {
                    'id': 'p1',
                    'question': 'Which pillar hides internal data representation?',
                    'options': ['Encapsulation', 'Polymorphism', 'Inheritance', 'Compilation'],
                    'correctIndex': 0,
                    'explanation': 'Encapsulation restricts direct access and bundles data.'
                  }
                ],
                'assessmentQuestions': [
                  {
                    'id': 'q1',
                    'question': 'A blueprint used to create objects is called a:',
                    'options': ['Method', 'Class', 'Variable', 'Pointer'],
                    'correctIndex': 1,
                    'explanation': 'A class defines the properties and behaviors of objects.'
                  }
                ]
              }
            }
          }
        }
      };

  // ──────────────────────────────────────────────────────────────────────────
  // CLASS 11
  // ──────────────────────────────────────────────────────────────────────────
  static Map<String, dynamic> _class11Curriculum() => {
        'id': 'computer_science',
        'title': 'Computer Science',
        'classLevel': 'class11',
        'description': 'Advanced data structures (Stacks, Queues, Trees) and algorithm complexity (Big O).',
        'chapters': {
          'ch1_data_structures': {
            'id': 'ch1_data_structures',
            'title': 'Chapter 1: Stacks and Queues',
            'description': 'LIFO and FIFO data structures.',
            'order': 1,
            'topics': {
              'top1_stacks': {
                'id': 'top1_stacks',
                'title': '1.1 Stack Data Structure (LIFO)',
                'description': 'Last-In, First-Out operations: push and pop.',
                'order': 1,
                'explanation': {
                  'title': 'Stack Mechanics and Operations',
                  'content': 'A Stack is a linear data structure that follows the Last-In, First-Out (LIFO) principle.\n\n### Primary Operations\n- **Push**: Adds an item to the top.\n- **Pop**: Removes the top item.\n- **Peek**: Views the top item without removing.'
                },
                'visualization': {
                  'type': 'flowchart',
                  'title': 'Stack Push/Pop Workflow',
                  'steps': ['Push Item C', 'Top is C', 'Pop Item C', 'Top is B']
                },
                'activity': {
                  'type': 'algorithm_ordering',
                  'title': 'Stack Operation Sequence',
                  'instruction': 'Order the stack operations for sequence [10, 20].',
                  'initialItems': [
                    'Pop top item (returns 20)',
                    'Push 20 onto stack',
                    'Push 10 onto stack',
                    'Pop top item (returns 10)'
                  ],
                  'correctOrder': [
                    'Push 10 onto stack',
                    'Push 20 onto stack',
                    'Pop top item (returns 20)',
                    'Pop top item (returns 10)'
                  ]
                },
                'practiceQuestions': [
                  {
                    'id': 'p1',
                    'question': 'Which principle does a Stack follow?',
                    'options': ['FIFO', 'LIFO', 'Random Access', 'Priority Queue'],
                    'correctIndex': 1,
                    'explanation': 'Stacks operate on Last-In, First-Out (LIFO).'
                  }
                ],
                'assessmentQuestions': [
                  {
                    'id': 'q1',
                    'question': 'Adding an item to a stack is called:',
                    'options': ['Enqueue', 'Push', 'Dequeue', 'Insert'],
                    'correctIndex': 1,
                    'explanation': 'Push adds an element to the top of the stack.'
                  }
                ]
              }
            }
          }
        }
      };

  // ──────────────────────────────────────────────────────────────────────────
  // CLASS 12
  // ──────────────────────────────────────────────────────────────────────────
  static Map<String, dynamic> _class12Curriculum() => {
        'id': 'computer_science',
        'title': 'Computer Science',
        'classLevel': 'class12',
        'description': 'Advanced algorithms, graph theory, distributed systems, and system design fundamentals.',
        'chapters': {
          'ch1_graph_algorithms': {
            'id': 'ch1_graph_algorithms',
            'title': 'Chapter 1: Graph Theory & Algorithms',
            'description': 'Vertices, edges, BFS, DFS, and shortest path algorithms.',
            'order': 1,
            'topics': {
              'top1_bfs_dfs': {
                'id': 'top1_bfs_dfs',
                'title': '1.1 Graph Traversals: BFS & DFS',
                'description': 'Breadth-First Search and Depth-First Search traversal strategies.',
                'order': 1,
                'explanation': {
                  'title': 'Graph Traversal Algorithms',
                  'content': 'Graphs are non-linear data structures consisting of vertices (nodes) and edges.\n\n### Traversals\n- **BFS (Breadth-First Search)**: Explores neighbor nodes level by level using a Queue.\n- **DFS (Depth-First Search)**: Explores as deep as possible along each branch using a Stack.'
                },
                'visualization': {
                  'type': 'diagram',
                  'title': 'BFS Queue Traversal',
                  'steps': ['Visit Start Node', 'Enqueue Neighbors', 'Dequeue & Visit Next Level']
                },
                'activity': {
                  'type': 'algorithm_ordering',
                  'title': 'BFS Step Sequence',
                  'instruction': 'Order the steps of Breadth-First Search.',
                  'initialItems': [
                    'Mark node as visited and dequeue',
                    'Enqueue adjacent unvisited nodes',
                    'Enqueue starting root node',
                    'While queue is not empty'
                  ],
                  'correctOrder': [
                    'Enqueue starting root node',
                    'While queue is not empty',
                    'Mark node as visited and dequeue',
                    'Enqueue adjacent unvisited nodes'
                  ]
                },
                'practiceQuestions': [
                  {
                    'id': 'p1',
                    'question': 'Which data structure is used to implement Breadth-First Search?',
                    'options': ['Stack', 'Queue', 'Array', 'Tree'],
                    'correctIndex': 1,
                    'explanation': 'BFS utilizes a Queue for level-order traversal (FIFO).'
                  }
                ],
                'assessmentQuestions': [
                  {
                    'id': 'q1',
                    'question': 'Which traversal explores depth-first using recursion or a stack?',
                    'options': ['BFS', 'DFS', 'Linear Search', 'Binary Search'],
                    'correctIndex': 1,
                    'explanation': 'DFS (Depth-First Search) goes deep down branches using a stack.'
                  }
                ]
              }
            }
          }
        }
      };
}
