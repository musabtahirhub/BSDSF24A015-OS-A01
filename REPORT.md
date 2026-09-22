# Operating Systems — Programming Assignment 01 Report

**Student Name:** Musab Tahir  
**Roll Number:** BSDSF24A015  
**Course:** Operating Systems  
**Instructor:** Muhammad Arif Butt, PhD  

---

## Feature-2: Multi-file Project using Make Utility

### 1. Linking Rule `$(TARGET): $(OBJECTS)` vs. Linking Against a Library
* **Direct Object Linking (`$(TARGET): $(OBJECTS)`):**  
  The linker takes every raw relocatable object file (`.o`) generated from the source files and combines them directly into the final executable. The linker inspects and merges all symbols and sections from each specified `.o` file unconditionally into a single binary image[cite: 1].
* **Linking Against a Library (`-L<dir> -l<name>`):**  
  Instead of passing individual `.o` files, the linker is pointed to an archive (`.a`) or shared object (`.so`)[cite: 1].
  * For a **static archive (`.a`)**, the linker only extracts and pulls into the final executable those specific object members that resolve currently undefined external symbols[cite: 1]. Unused object files inside the archive are excluded, keeping binary bloat minimal.
  * For a **dynamic shared library (`.so`)**, the linker copies no functional code into the binary[cite: 1]. Instead, it writes dynamic relocation tags, symbols, and dependency records so that the runtime dynamic loader (`ld.so`) can resolve and bind the symbols when the executable starts up[cite: 1].

### 2. Git Tags: Purpose, Usefulness, and Differences
* **What a Git Tag Is:**  
  A Git tag is an explicit, permanent reference that points to a specific commit hash in the repository's history[cite: 1]. Tags act as immutable version milestones (e.g., semantic versions like `v1.0-multifile` or `v0.2.1-static`) so developers and users can check out or reference exact release states without tracking fluctuating branch tips[cite: 1].
* **Lightweight vs. Annotated Tags:**
  * **Lightweight Tag:** Simply a named pointer/bookmark to a commit (stored as a simple file in `.git/refs/tags/` containing just the 40-character commit hash). It stores no extra metadata.
  * **Annotated Tag (`git tag -a`):** Stored as a complete Git object in the Git object database[cite: 1]. It includes its own unique SHA checksum, the tagger's name, email, timestamp, and a dedicated release message[cite: 1]. Annotated tags are standard for public software releases[cite: 1].

### 3. GitHub Releases and Attaching Binaries
* **Purpose of GitHub Releases:**  
  GitHub Releases serve as official software distribution points built around Git tags[cite: 1]. They allow maintainers to package source code snapshots together with release notes, changelogs, and production assets for end users[cite: 1].
* **Significance of Attaching Binaries:**  
  Attaching pre-compiled binaries (such as `bin/client` or `libmyutils.so`) allows consumers to download and execute the program immediately without requiring a local C compiler (`gcc`), the `make` utility, header files, or build dependencies installed on their machine[cite: 1].

---

## Feature-3: Creating and Using Static Library

### 1. Makefile Differences Between Feature 2 and Feature 3
* **In Feature 2:** The Makefile compiled all `.c` files to `.o` files and directly linked them into `bin/client` using `gcc $(OBJS) -o $(TARGET)`[cite: 1].
* **In Feature 3:** A new intermediate build stage is introduced[cite: 1]:
  1. The utility object files (`obj/mystrfunctions.o` and `obj/myfilefunctions.o`) are packaged into an archive library `lib/libmyutils.a` using the `ar` utility[cite: 1].
  2. The linking rule for `bin/client_static` no longer references the individual utility `.o` files; it depends on `obj/main.o` and `lib/libmyutils.a`[cite: 1]. The linker command is modified to link against the archive directly (`obj/main.o lib/libmyutils.a -o bin/client_static` or using `-Llib -lmyutils`)[cite: 1].

### 2. Purpose of `ar` and Why `ranlib` is Used
* **`ar` (Archiver):** A Unix utility that creates, modifies, and extracts from archives[cite: 1]. In C programming, it groups individual compiled object files (`.o`) into a single archive library file (`.a`)[cite: 1].
* **`ranlib`:** Generates or updates an internal symbol table (index) inside the archive header. This index maps function/symbol names to the corresponding `.o` member within the archive, allowing the linker to quickly resolve external references in a single pass without scanning every individual object file linearly.
* *Note:* When creating an archive using `ar rcs`, the `s` flag automatically writes or updates this symbol table, making a separate manual call to `ranlib` optional[cite: 1].

### 3. Symbol Analysis via `nm` on `client_static`
* When running `nm bin/client_static | grep mystrlen`, the symbol `mystrlen` appears in the output with the symbol type **`T`** (Text / Code section)[cite: 1].
* **What this reveals about static linking:**  
  It proves that during static linking, the linker extracted the compiled machine code for `mystrlen` from `libmyutils.a` and physically copied its instructions directly into the executable's `.text` segment[cite: 1]. The executable becomes self-sufficient and does not rely on external library files on disk at runtime to run `mystrlen`[cite: 1].

---

## Feature-4: Creating and Using Dynamic Library

### 1. Position-Independent Code (`-fPIC`) and Shared Libraries
* **What `-fPIC` Is:**  
  Position-Independent Code (`-fPIC`) instructs the compiler to generate machine code instructions that use relative memory addressing rather than absolute virtual memory addresses[cite: 1].
* **Why it is fundamental for shared libraries:**  
  Unlike static executables where code sections are linked at a fixed, predefined base virtual address, a shared library (`.so`) can be loaded into arbitrary, unpredictable memory locations across different processes at runtime[cite: 1].  
  By using `-fPIC`, the code accesses global data and external functions through indirection tables—specifically the **Global Offset Table (GOT)** and the **Procedure Linkage Table (PLT)**. This ensures that the code segment (`.text`) remains completely read-only and can be shared among hundreds of concurrent processes in physical RAM without modifying code in place[cite: 1].

### 2. File Size Differences Between Static and Dynamic Clients
* **Observation:** `bin/client_static` is larger than `bin/client_dynamic`[cite: 1]. (If compiled with `-static`, `client_static` is roughly 800 KB–1 MB, whereas `client_dynamic` is approximately 16–17 KB)[cite: 10].
* **Why this difference exists:**  
  * **Static Linking:** The linker extracts and embeds the actual machine code instructions of the library functions directly into the executable binary[cite: 1]. If fully static, the entire C runtime library (`libc`) routines (e.g., `printf`, `fopen`, memory allocation routines) are embedded inside the binary file.
  * **Dynamic Linking:** The executable contains no implementation code for library functions[cite: 1]. It only contains lightweight symbol stubs, string identifiers, and relocation references in the PLT/GOT, leaving the actual heavy machine code inside the standalone `libmyutils.so` and `libc.so` shared files[cite: 1].

### 3. `LD_LIBRARY_PATH` and the Role of the Dynamic Loader
* **What `LD_LIBRARY_PATH` Is:**  
  `LD_LIBRARY_PATH` is an environment variable containing a colon-separated list of filesystem directories where the Linux dynamic loader (`ld.so` / `ld-linux.so`) searches for shared libraries (`.so` files) *before* checking standard system library directories[cite: 1, 9].
* **Why it was necessary to set it:**  
  When running `./bin/client_dynamic`, the operating system threw an error: `cannot open shared object file: No such file or directory`[cite: 1]. This occurred because our custom library `libmyutils.so` was located in a local non-standard directory (`./lib`) rather than a default system path (such as `/lib`, `/usr/lib`, or paths listed in `/etc/ld.so.conf`)[cite: 1]. Setting `export LD_LIBRARY_PATH=$PWD/lib:$LD_LIBRARY_PATH` instructed the runtime loader to look inside our project's `lib` directory[cite: 1].
* **Responsibilities of the Dynamic Loader:**  
  This demonstrates that the operating system's dynamic loader is responsible for runtime binding: inspecting the executable's `DT_NEEDED` ELF headers, finding the required `.so` files across search paths, mapping their code and data into the process's virtual address space, resolving relocation addresses, and binding external function pointers before executing `main()`[cite: 1].