```
         <carl> Hello, I have a question about how valadoc generate files for built-in third party vapi. I looked at some vapi file (like gio for example) and didn't found any comment in it.
12:09 PM <carl> How does valadoc do that? How can I regenerate the valadoc for gio or other third party vapi for which I don't have vala source?
12:20 PM <flo> hey
12:20 PM <carl> hello!
12:21 PM <flo> it picks up external files and import documentation.
12:21 PM <flo> .valadoc-files (which are basically valadoc-comments with the node name below) and GIR files.
12:21 PM <flo> For GIO, we use both.
12:21 PM <flo> GIR for the main thing and .valadoc-files to append examples.
12:23 PM <carl> What I'm trying to do is to understand valadoc works wit GIR files so I can improve doc (fixing typos and providing alternative css styling).
12:23 PM <carl> If I needed to rebuild valadoc for gio locally, what should I do?
12:24 PM <carl> Dowload gio's gir files and run through valadoc (I can leave samples out for now)?
12:24 PM <flo> thats one possibility, yes
12:24 PM <carl> run it through *
12:24 PM <flo> so, basically, in case typos originate in gir files, you have to fix them upstream
12:25 PM <flo> (so for gio, its glibs git repo)
12:25 PM <carl> Indeed. But before submitting patches, I want to be sure that everything checks out locally.
12:26 PM <flo> I don't have any vala-stuff on the machine I am right now, this is just based on memory:
12:26 PM <flo> there is an --import flag and an --importdir one
12:26 PM <flo> basically, set --importdir to your gir directory and use --import to pass the gir file name
12:27 PM <flo> and pass the vapi path directly to valadoc
12:27 PM <flo> that should do the trick
12:27 PM <carl> Can I update the comments directly in the gir file, checks that everything looks good (and makes sense) and then propose the real patch for the actual files that generated the gir file?
12:27 PM <carl> Okay, thanks for the heads up. I'll work from your outline.
12:27 PM <flo> yes, that should work
12:28 PM <flo> don't forget that some dead links might be there because we do not have the linked symbol in our bindings
12:29 PM <flo> we also only process docbook or markdown, so in case you find broken xml somewhere, it should be translated to markdown if possible.
12:30 PM <carl> Okay. I'll keep that in mind.
12:31 PM <flo> gtg for an hour or so, thansk for caring about that
12:31 PM <carl> Gir files are generated during the compilation of the library, right? There is no central repository from them. I have to rebuild the library (gio in my example) to get the gir file, right?
12:32 PM <carl> No problem thanks for your help.
12:32 PM <flo> yes but nemequ maintains a repository for me
12:32 PM <flo> basically the gir files we use for docs and vapis in master
12:32 PM <flo> https://github.com/nemequ/vala-girs
```

## How to build packagekit docs



[Source for valadoc.org](https://gitorious.org/valadoc-org/valadoc-org)
