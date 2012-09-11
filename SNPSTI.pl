#!/usr/bin/perl

#This script was copied from version 1.11 of SNPSTI.pl and is enhanced to run
#in low_memory mode with the -l option (slower, but uses less memory)

#Robert W. Leach
#9/11/2012
#Center for Computational Research
#Copyright 2012

#                    GNU GENERAL PUBLIC LICENSE
#                       Version 3, 29 June 2007
#
# Copyright (C) 2007 Free Software Foundation, Inc. <http://fsf.org/>
# Everyone is permitted to copy and distribute verbatim copies
# of this license document, but changing it is not allowed.
#
#                            Preamble
#
#  The GNU General Public License is a free, copyleft license for
#software and other kinds of works.
#
#  The licenses for most software and other practical works are designed
#to take away your freedom to share and change the works.  By contrast,
#the GNU General Public License is intended to guarantee your freedom to
#share and change all versions of a program--to make sure it remains free
#software for all its users.  We, the Free Software Foundation, use the
#GNU General Public License for most of our software; it applies also to
#any other work released this way by its authors.  You can apply it to
#your programs, too.
#
#  When we speak of free software, we are referring to freedom, not
#price.  Our General Public Licenses are designed to make sure that you
#have the freedom to distribute copies of free software (and charge for
#them if you wish), that you receive source code or can get it if you
#want it, that you can change the software or use pieces of it in new
#free programs, and that you know you can do these things.
#
#  To protect your rights, we need to prevent others from denying you
#these rights or asking you to surrender the rights.  Therefore, you have
#certain responsibilities if you distribute copies of the software, or if
#you modify it: responsibilities to respect the freedom of others.
#
#  For example, if you distribute copies of such a program, whether
#gratis or for a fee, you must pass on to the recipients the same
#freedoms that you received.  You must make sure that they, too, receive
#or can get the source code.  And you must show them these terms so they
#know their rights.
#
#  Developers that use the GNU GPL protect your rights with two steps:
#(1) assert copyright on the software, and (2) offer you this License
#giving you legal permission to copy, distribute and/or modify it.
#
#  For the developers' and authors' protection, the GPL clearly explains
#that there is no warranty for this free software.  For both users' and
#authors' sake, the GPL requires that modified versions be marked as
#changed, so that their problems will not be attributed erroneously to
#authors of previous versions.
#
#  Some devices are designed to deny users access to install or run
#modified versions of the software inside them, although the manufacturer
#can do so.  This is fundamentally incompatible with the aim of
#protecting users' freedom to change the software.  The systematic
#pattern of such abuse occurs in the area of products for individuals to
#use, which is precisely where it is most unacceptable.  Therefore, we
#have designed this version of the GPL to prohibit the practice for those
#products.  If such problems arise substantially in other domains, we
#stand ready to extend this provision to those domains in future versions
#of the GPL, as needed to protect the freedom of users.
#
#  Finally, every program is threatened constantly by software patents.
#States should not allow patents to restrict development and use of
#software on general-purpose computers, but in those that do, we wish to
#avoid the special danger that patents applied to a free program could
#make it effectively proprietary.  To prevent this, the GPL assures that
#patents cannot be used to render the program non-free.
#
#  The precise terms and conditions for copying, distribution and
#modification follow.
#
#                       TERMS AND CONDITIONS
#
#  0. Definitions.
#
#  "This License" refers to version 3 of the GNU General Public License.
#
#  "Copyright" also means copyright-like laws that apply to other kinds of
#works, such as semiconductor masks.
#
#  "The Program" refers to any copyrightable work licensed under this
#License.  Each licensee is addressed as "you".  "Licensees" and
#"recipients" may be individuals or organizations.
#
#  To "modify" a work means to copy from or adapt all or part of the work
#in a fashion requiring copyright permission, other than the making of an
#exact copy.  The resulting work is called a "modified version" of the
#earlier work or a work "based on" the earlier work.
#
#  A "covered work" means either the unmodified Program or a work based
#on the Program.
#
#  To "propagate" a work means to do anything with it that, without
#permission, would make you directly or secondarily liable for
#infringement under applicable copyright law, except executing it on a
#computer or modifying a private copy.  Propagation includes copying,
#distribution (with or without modification), making available to the
#public, and in some countries other activities as well.
#
#  To "convey" a work means any kind of propagation that enables other
#parties to make or receive copies.  Mere interaction with a user through
#a computer network, with no transfer of a copy, is not conveying.
#
#  An interactive user interface displays "Appropriate Legal Notices"
#to the extent that it includes a convenient and prominently visible
#feature that (1) displays an appropriate copyright notice, and (2)
#tells the user that there is no warranty for the work (except to the
#extent that warranties are provided), that licensees may convey the
#work under this License, and how to view a copy of this License.  If
#the interface presents a list of user commands or options, such as a
#menu, a prominent item in the list meets this criterion.
#
#  1. Source Code.
#
#  The "source code" for a work means the preferred form of the work
#for making modifications to it.  "Object code" means any non-source
#form of a work.
#
#  A "Standard Interface" means an interface that either is an official
#standard defined by a recognized standards body, or, in the case of
#interfaces specified for a particular programming language, one that
#is widely used among developers working in that language.
#
#  The "System Libraries" of an executable work include anything, other
#than the work as a whole, that (a) is included in the normal form of
#packaging a Major Component, but which is not part of that Major
#Component, and (b) serves only to enable use of the work with that
#Major Component, or to implement a Standard Interface for which an
#implementation is available to the public in source code form.  A
#"Major Component", in this context, means a major essential component
#(kernel, window system, and so on) of the specific operating system
#(if any) on which the executable work runs, or a compiler used to
#produce the work, or an object code interpreter used to run it.
#
#  The "Corresponding Source" for a work in object code form means all
#the source code needed to generate, install, and (for an executable
#work) run the object code and to modify the work, including scripts to
#control those activities.  However, it does not include the work's
#System Libraries, or general-purpose tools or generally available free
#programs which are used unmodified in performing those activities but
#which are not part of the work.  For example, Corresponding Source
#includes interface definition files associated with source files for
#the work, and the source code for shared libraries and dynamically
#linked subprograms that the work is specifically designed to require,
#such as by intimate data communication or control flow between those
#subprograms and other parts of the work.
#
#  The Corresponding Source need not include anything that users
#can regenerate automatically from other parts of the Corresponding
#Source.
#
#  The Corresponding Source for a work in source code form is that
#same work.
#
#  2. Basic Permissions.
#
#  All rights granted under this License are granted for the term of
#copyright on the Program, and are irrevocable provided the stated
#conditions are met.  This License explicitly affirms your unlimited
#permission to run the unmodified Program.  The output from running a
#covered work is covered by this License only if the output, given its
#content, constitutes a covered work.  This License acknowledges your
#rights of fair use or other equivalent, as provided by copyright law.
#
#  You may make, run and propagate covered works that you do not
#convey, without conditions so long as your license otherwise remains
#in force.  You may convey covered works to others for the sole purpose
#of having them make modifications exclusively for you, or provide you
#with facilities for running those works, provided that you comply with
#the terms of this License in conveying all material for which you do
#not control copyright.  Those thus making or running the covered works
#for you must do so exclusively on your behalf, under your direction
#and control, on terms that prohibit them from making any copies of
#your copyrighted material outside their relationship with you.
#
#  Conveying under any other circumstances is permitted solely under
#the conditions stated below.  Sublicensing is not allowed; section 10
#makes it unnecessary.
#
#  3. Protecting Users' Legal Rights From Anti-Circumvention Law.
#
#  No covered work shall be deemed part of an effective technological
#measure under any applicable law fulfilling obligations under article
#11 of the WIPO copyright treaty adopted on 20 December 1996, or
#similar laws prohibiting or restricting circumvention of such
#measures.
#
#  When you convey a covered work, you waive any legal power to forbid
#circumvention of technological measures to the extent such circumvention
#is effected by exercising rights under this License with respect to
#the covered work, and you disclaim any intention to limit operation or
#modification of the work as a means of enforcing, against the work's
#users, your or third parties' legal rights to forbid circumvention of
#technological measures.
#
#  4. Conveying Verbatim Copies.
#
#  You may convey verbatim copies of the Program's source code as you
#receive it, in any medium, provided that you conspicuously and
#appropriately publish on each copy an appropriate copyright notice;
#keep intact all notices stating that this License and any
#non-permissive terms added in accord with section 7 apply to the code;
#keep intact all notices of the absence of any warranty; and give all
#recipients a copy of this License along with the Program.
#
#  You may charge any price or no price for each copy that you convey,
#and you may offer support or warranty protection for a fee.
#
#  5. Conveying Modified Source Versions.
#
#  You may convey a work based on the Program, or the modifications to
#produce it from the Program, in the form of source code under the
#terms of section 4, provided that you also meet all of these conditions:
#
#    a) The work must carry prominent notices stating that you modified
#    it, and giving a relevant date.
#
#    b) The work must carry prominent notices stating that it is
#    released under this License and any conditions added under section
#    7.  This requirement modifies the requirement in section 4 to
#    "keep intact all notices".
#
#    c) You must license the entire work, as a whole, under this
#    License to anyone who comes into possession of a copy.  This
#    License will therefore apply, along with any applicable section 7
#    additional terms, to the whole of the work, and all its parts,
#    regardless of how they are packaged.  This License gives no
#    permission to license the work in any other way, but it does not
#    invalidate such permission if you have separately received it.
#
#    d) If the work has interactive user interfaces, each must display
#    Appropriate Legal Notices; however, if the Program has interactive
#    interfaces that do not display Appropriate Legal Notices, your
#    work need not make them do so.
#
#  A compilation of a covered work with other separate and independent
#works, which are not by their nature extensions of the covered work,
#and which are not combined with it such as to form a larger program,
#in or on a volume of a storage or distribution medium, is called an
#"aggregate" if the compilation and its resulting copyright are not
#used to limit the access or legal rights of the compilation's users
#beyond what the individual works permit.  Inclusion of a covered work
#in an aggregate does not cause this License to apply to the other
#parts of the aggregate.
#
#  6. Conveying Non-Source Forms.
#
#  You may convey a covered work in object code form under the terms
#of sections 4 and 5, provided that you also convey the
#machine-readable Corresponding Source under the terms of this License,
#in one of these ways:
#
#    a) Convey the object code in, or embodied in, a physical product
#    (including a physical distribution medium), accompanied by the
#    Corresponding Source fixed on a durable physical medium
#    customarily used for software interchange.
#
#    b) Convey the object code in, or embodied in, a physical product
#    (including a physical distribution medium), accompanied by a
#    written offer, valid for at least three years and valid for as
#    long as you offer spare parts or customer support for that product
#    model, to give anyone who possesses the object code either (1) a
#    copy of the Corresponding Source for all the software in the
#    product that is covered by this License, on a durable physical
#    medium customarily used for software interchange, for a price no
#    more than your reasonable cost of physically performing this
#    conveying of source, or (2) access to copy the
#    Corresponding Source from a network server at no charge.
#
#    c) Convey individual copies of the object code with a copy of the
#    written offer to provide the Corresponding Source.  This
#    alternative is allowed only occasionally and noncommercially, and
#    only if you received the object code with such an offer, in accord
#    with subsection 6b.
#
#    d) Convey the object code by offering access from a designated
#    place (gratis or for a charge), and offer equivalent access to the
#    Corresponding Source in the same way through the same place at no
#    further charge.  You need not require recipients to copy the
#    Corresponding Source along with the object code.  If the place to
#    copy the object code is a network server, the Corresponding Source
#    may be on a different server (operated by you or a third party)
#    that supports equivalent copying facilities, provided you maintain
#    clear directions next to the object code saying where to find the
#    Corresponding Source.  Regardless of what server hosts the
#    Corresponding Source, you remain obligated to ensure that it is
#    available for as long as needed to satisfy these requirements.
#
#    e) Convey the object code using peer-to-peer transmission, provided
#    you inform other peers where the object code and Corresponding
#    Source of the work are being offered to the general public at no
#    charge under subsection 6d.
#
#  A separable portion of the object code, whose source code is excluded
#from the Corresponding Source as a System Library, need not be
#included in conveying the object code work.
#
#  A "User Product" is either (1) a "consumer product", which means any
#tangible personal property which is normally used for personal, family,
#or household purposes, or (2) anything designed or sold for incorporation
#into a dwelling.  In determining whether a product is a consumer product,
#doubtful cases shall be resolved in favor of coverage.  For a particular
#product received by a particular user, "normally used" refers to a
#typical or common use of that class of product, regardless of the status
#of the particular user or of the way in which the particular user
#actually uses, or expects or is expected to use, the product.  A product
#is a consumer product regardless of whether the product has substantial
#commercial, industrial or non-consumer uses, unless such uses represent
#the only significant mode of use of the product.
#
#  "Installation Information" for a User Product means any methods,
#procedures, authorization keys, or other information required to install
#and execute modified versions of a covered work in that User Product from
#a modified version of its Corresponding Source.  The information must
#suffice to ensure that the continued functioning of the modified object
#code is in no case prevented or interfered with solely because
#modification has been made.
#
#  If you convey an object code work under this section in, or with, or
#specifically for use in, a User Product, and the conveying occurs as
#part of a transaction in which the right of possession and use of the
#User Product is transferred to the recipient in perpetuity or for a
#fixed term (regardless of how the transaction is characterized), the
#Corresponding Source conveyed under this section must be accompanied
#by the Installation Information.  But this requirement does not apply
#if neither you nor any third party retains the ability to install
#modified object code on the User Product (for example, the work has
#been installed in ROM).
#
#  The requirement to provide Installation Information does not include a
#requirement to continue to provide support service, warranty, or updates
#for a work that has been modified or installed by the recipient, or for
#the User Product in which it has been modified or installed.  Access to a
#network may be denied when the modification itself materially and
#adversely affects the operation of the network or violates the rules and
#protocols for communication across the network.
#
#  Corresponding Source conveyed, and Installation Information provided,
#in accord with this section must be in a format that is publicly
#documented (and with an implementation available to the public in
#source code form), and must require no special password or key for
#unpacking, reading or copying.
#
#  7. Additional Terms.
#
#  "Additional permissions" are terms that supplement the terms of this
#License by making exceptions from one or more of its conditions.
#Additional permissions that are applicable to the entire Program shall
#be treated as though they were included in this License, to the extent
#that they are valid under applicable law.  If additional permissions
#apply only to part of the Program, that part may be used separately
#under those permissions, but the entire Program remains governed by
#this License without regard to the additional permissions.
#
#  When you convey a copy of a covered work, you may at your option
#remove any additional permissions from that copy, or from any part of
#it.  (Additional permissions may be written to require their own
#removal in certain cases when you modify the work.)  You may place
#additional permissions on material, added by you to a covered work,
#for which you have or can give appropriate copyright permission.
#
#  Notwithstanding any other provision of this License, for material you
#add to a covered work, you may (if authorized by the copyright holders of
#that material) supplement the terms of this License with terms:
#
#    a) Disclaiming warranty or limiting liability differently from the
#    terms of sections 15 and 16 of this License; or
#
#    b) Requiring preservation of specified reasonable legal notices or
#    author attributions in that material or in the Appropriate Legal
#    Notices displayed by works containing it; or
#
#    c) Prohibiting misrepresentation of the origin of that material, or
#    requiring that modified versions of such material be marked in
#    reasonable ways as different from the original version; or
#
#    d) Limiting the use for publicity purposes of names of licensors or
#    authors of the material; or
#
#    e) Declining to grant rights under trademark law for use of some
#    trade names, trademarks, or service marks; or
#
#    f) Requiring indemnification of licensors and authors of that
#    material by anyone who conveys the material (or modified versions of
#    it) with contractual assumptions of liability to the recipient, for
#    any liability that these contractual assumptions directly impose on
#    those licensors and authors.
#
#  All other non-permissive additional terms are considered "further
#restrictions" within the meaning of section 10.  If the Program as you
#received it, or any part of it, contains a notice stating that it is
#governed by this License along with a term that is a further
#restriction, you may remove that term.  If a license document contains
#a further restriction but permits relicensing or conveying under this
#License, you may add to a covered work material governed by the terms
#of that license document, provided that the further restriction does
#not survive such relicensing or conveying.
#
#  If you add terms to a covered work in accord with this section, you
#must place, in the relevant source files, a statement of the
#additional terms that apply to those files, or a notice indicating
#where to find the applicable terms.
#
#  Additional terms, permissive or non-permissive, may be stated in the
#form of a separately written license, or stated as exceptions;
#the above requirements apply either way.
#
#  8. Termination.
#
#  You may not propagate or modify a covered work except as expressly
#provided under this License.  Any attempt otherwise to propagate or
#modify it is void, and will automatically terminate your rights under
#this License (including any patent licenses granted under the third
#paragraph of section 11).
#
#  However, if you cease all violation of this License, then your
#license from a particular copyright holder is reinstated (a)
#provisionally, unless and until the copyright holder explicitly and
#finally terminates your license, and (b) permanently, if the copyright
#holder fails to notify you of the violation by some reasonable means
#prior to 60 days after the cessation.
#
#  Moreover, your license from a particular copyright holder is
#reinstated permanently if the copyright holder notifies you of the
#violation by some reasonable means, this is the first time you have
#received notice of violation of this License (for any work) from that
#copyright holder, and you cure the violation prior to 30 days after
#your receipt of the notice.
#
#  Termination of your rights under this section does not terminate the
#licenses of parties who have received copies or rights from you under
#this License.  If your rights have been terminated and not permanently
#reinstated, you do not qualify to receive new licenses for the same
#material under section 10.
#
#  9. Acceptance Not Required for Having Copies.
#
#  You are not required to accept this License in order to receive or
#run a copy of the Program.  Ancillary propagation of a covered work
#occurring solely as a consequence of using peer-to-peer transmission
#to receive a copy likewise does not require acceptance.  However,
#nothing other than this License grants you permission to propagate or
#modify any covered work.  These actions infringe copyright if you do
#not accept this License.  Therefore, by modifying or propagating a
#covered work, you indicate your acceptance of this License to do so.
#
#  10. Automatic Licensing of Downstream Recipients.
#
#  Each time you convey a covered work, the recipient automatically
#receives a license from the original licensors, to run, modify and
#propagate that work, subject to this License.  You are not responsible
#for enforcing compliance by third parties with this License.
#
#  An "entity transaction" is a transaction transferring control of an
#organization, or substantially all assets of one, or subdividing an
#organization, or merging organizations.  If propagation of a covered
#work results from an entity transaction, each party to that
#transaction who receives a copy of the work also receives whatever
#licenses to the work the party's predecessor in interest had or could
#give under the previous paragraph, plus a right to possession of the
#Corresponding Source of the work from the predecessor in interest, if
#the predecessor has it or can get it with reasonable efforts.
#
#  You may not impose any further restrictions on the exercise of the
#rights granted or affirmed under this License.  For example, you may
#not impose a license fee, royalty, or other charge for exercise of
#rights granted under this License, and you may not initiate litigation
#(including a cross-claim or counterclaim in a lawsuit) alleging that
#any patent claim is infringed by making, using, selling, offering for
#sale, or importing the Program or any portion of it.
#
#  11. Patents.
#
#  A "contributor" is a copyright holder who authorizes use under this
#License of the Program or a work on which the Program is based.  The
#work thus licensed is called the contributor's "contributor version".
#
#  A contributor's "essential patent claims" are all patent claims
#owned or controlled by the contributor, whether already acquired or
#hereafter acquired, that would be infringed by some manner, permitted
#by this License, of making, using, or selling its contributor version,
#but do not include claims that would be infringed only as a
#consequence of further modification of the contributor version.  For
#purposes of this definition, "control" includes the right to grant
#patent sublicenses in a manner consistent with the requirements of
#this License.
#
#  Each contributor grants you a non-exclusive, worldwide, royalty-free
#patent license under the contributor's essential patent claims, to
#make, use, sell, offer for sale, import and otherwise run, modify and
#propagate the contents of its contributor version.
#
#  In the following three paragraphs, a "patent license" is any express
#agreement or commitment, however denominated, not to enforce a patent
#(such as an express permission to practice a patent or covenant not to
#sue for patent infringement).  To "grant" such a patent license to a
#party means to make such an agreement or commitment not to enforce a
#patent against the party.
#
#  If you convey a covered work, knowingly relying on a patent license,
#and the Corresponding Source of the work is not available for anyone
#to copy, free of charge and under the terms of this License, through a
#publicly available network server or other readily accessible means,
#then you must either (1) cause the Corresponding Source to be so
#available, or (2) arrange to deprive yourself of the benefit of the
#patent license for this particular work, or (3) arrange, in a manner
#consistent with the requirements of this License, to extend the patent
#license to downstream recipients.  "Knowingly relying" means you have
#actual knowledge that, but for the patent license, your conveying the
#covered work in a country, or your recipient's use of the covered work
#in a country, would infringe one or more identifiable patents in that
#country that you have reason to believe are valid.
#
#  If, pursuant to or in connection with a single transaction or
#arrangement, you convey, or propagate by procuring conveyance of, a
#covered work, and grant a patent license to some of the parties
#receiving the covered work authorizing them to use, propagate, modify
#or convey a specific copy of the covered work, then the patent license
#you grant is automatically extended to all recipients of the covered
#work and works based on it.
#
#  A patent license is "discriminatory" if it does not include within
#the scope of its coverage, prohibits the exercise of, or is
#conditioned on the non-exercise of one or more of the rights that are
#specifically granted under this License.  You may not convey a covered
#work if you are a party to an arrangement with a third party that is
#in the business of distributing software, under which you make payment
#to the third party based on the extent of your activity of conveying
#the work, and under which the third party grants, to any of the
#parties who would receive the covered work from you, a discriminatory
#patent license (a) in connection with copies of the covered work
#conveyed by you (or copies made from those copies), or (b) primarily
#for and in connection with specific products or compilations that
#contain the covered work, unless you entered into that arrangement,
#or that patent license was granted, prior to 28 March 2007.
#
#  Nothing in this License shall be construed as excluding or limiting
#any implied license or other defenses to infringement that may
#otherwise be available to you under applicable patent law.
#
#  12. No Surrender of Others' Freedom.
#
#  If conditions are imposed on you (whether by court order, agreement or
#otherwise) that contradict the conditions of this License, they do not
#excuse you from the conditions of this License.  If you cannot convey a
#covered work so as to satisfy simultaneously your obligations under this
#License and any other pertinent obligations, then as a consequence you may
#not convey it at all.  For example, if you agree to terms that obligate you
#to collect a royalty for further conveying from those to whom you convey
#the Program, the only way you could satisfy both those terms and this
#License would be to refrain entirely from conveying the Program.
#
#  13. Use with the GNU Affero General Public License.
#
#  Notwithstanding any other provision of this License, you have
#permission to link or combine any covered work with a work licensed
#under version 3 of the GNU Affero General Public License into a single
#combined work, and to convey the resulting work.  The terms of this
#License will continue to apply to the part which is the covered work,
#but the special requirements of the GNU Affero General Public License,
#section 13, concerning interaction through a network will apply to the
#combination as such.
#
#  14. Revised Versions of this License.
#
#  The Free Software Foundation may publish revised and/or new versions of
#the GNU General Public License from time to time.  Such new versions will
#be similar in spirit to the present version, but may differ in detail to
#address new problems or concerns.
#
#  Each version is given a distinguishing version number.  If the
#Program specifies that a certain numbered version of the GNU General
#Public License "or any later version" applies to it, you have the
#option of following the terms and conditions either of that numbered
#version or of any later version published by the Free Software
#Foundation.  If the Program does not specify a version number of the
#GNU General Public License, you may choose any version ever published
#by the Free Software Foundation.
#
#  If the Program specifies that a proxy can decide which future
#versions of the GNU General Public License can be used, that proxy's
#public statement of acceptance of a version permanently authorizes you
#to choose that version for the Program.
#
#  Later license versions may give you additional or different
#permissions.  However, no additional obligations are imposed on any
#author or copyright holder as a result of your choosing to follow a
#later version.
#
#  15. Disclaimer of Warranty.
#
#  THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY
#APPLICABLE LAW.  EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT
#HOLDERS AND/OR OTHER PARTIES PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY
#OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO,
#THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
#PURPOSE.  THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM
#IS WITH YOU.  SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF
#ALL NECESSARY SERVICING, REPAIR OR CORRECTION.
#
#  16. Limitation of Liability.
#
#  IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
#WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MODIFIES AND/OR CONVEYS
#THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY
#GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE
#USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS OF
#DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD
#PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER PROGRAMS),
#EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
#SUCH DAMAGES.
#
#  17. Interpretation of Sections 15 and 16.
#
#  If the disclaimer of warranty and limitation of liability provided
#above cannot be given local legal effect according to their terms,
#reviewing courts shall apply local law that most closely approximates
#an absolute waiver of all civil liability in connection with the
#Program, unless a warranty or assumption of liability accompanies a
#copy of the Program in return for a fee.
#
#                     END OF TERMS AND CONDITIONS
#
#            How to Apply These Terms to Your New Programs
#
#  If you develop a new program, and you want it to be of the greatest
#possible use to the public, the best way to achieve this is to make it
#free software which everyone can redistribute and change under these terms.
#
#  To do so, attach the following notices to the program.  It is safest
#to attach them to the start of each source file to most effectively
#state the exclusion of warranty; and each file should have at least
#the "copyright" line and a pointer to where the full notice is found.
#
#    <one line to give the program's name and a brief idea of what it does.>
#    Copyright (C) <year>  <name of author>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#Also add information on how to contact you by electronic and paper mail.
#
#  If the program does terminal interaction, make it output a short
#notice like this when it starts in an interactive mode:
#
#    <program>  Copyright (C) <year>  <name of author>
#    This program comes with ABSOLUTELY NO WARRANTY; for details type `show w'.
#    This is free software, and you are welcome to redistribute it
#    under certain conditions; type `show c' for details.
#
#The hypothetical commands `show w' and `show c' should show the appropriate
#parts of the General Public License.  Of course, your program's commands
#might be different; for a GUI interface, you would use an "about box".
#
#  You should also get your employer (if you work as a programmer) or school,
#if any, to sign a "copyright disclaimer" for the program, if necessary.
#For more information on this, and how to apply and follow the GNU GPL, see
#<http://www.gnu.org/licenses/>.
#
#  The GNU General Public License does not permit incorporating your program
#into proprietary programs.  If your program is a subroutine library, you
#may consider it more useful to permit linking proprietary applications with
#the library.  If this is what you want to do, use the GNU Lesser General
#Public License instead of this License.  But first, please read
#<http://www.gnu.org/philosophy/why-not-lgpl.html>.

#USAGE: SNPSTI.pl -s SNP_infile -t Tree_infile [-v] [-h] [-m num] [-n num]
#Execute SNPSTI.pl -h to see a description of this program

#Keep track of the programs running time (reported in verbose mode)
my $time = time();

#Set the buffer to autoflush
$| = 1;

#Set up a path to the tree module on the cluster using the environment variable
#"SNPSTI_CLUSTER_TREE_PATH"
BEGIN
  {
    if(exists($ENV{SNPSTI_CLUSTER_TREE_PATH}) &&
       $ENV{SNPSTI_CLUSTER_TREE_PATH} ne '')
      {eval("use lib $ENV{SNPSTI_CLUSTER_TREE_PATH};1")}
  }

#If this is a run on the cluster, read in arguments from the environment
#variable "SNPSTI_CLUSTER_PARAMS"
my $cluster_run = 0;
my $host = (exists($ENV{HOSTNAME}) ?
	    $ENV{HOSTNAME} :
	    (exists($ENV{HOST}) ?
	     $ENV{HOST} : `hostname`));
chomp($host);
if(scalar(@ARGV) == 0 &&
   exists($ENV{SNPSTI_CLUSTER_PARAMS}) &&
   $ENV{SNPSTI_CLUSTER_PARAMS} ne '')
  {
    @ARGV = glob($ENV{SNPSTI_CLUSTER_PARAMS});
    $cluster_run = 1;
  }
if(exists($ENV{SNPSTI_CLUSTER_TREE_PATH}))
  {$cluster_run = 1}

#Declare/initialize variables
my $framesort_warning = 0;  #Global variable for isSolution
my $snp_names         = [];
my $genome_names      = [];
my $non_binary_nodes  = [];
my $all_snps_used     = {};
my $solutions         = {};
my $snp_data_buffer   = [];
my $partial_suffix    = '.prtl';
my($treefile,$snpfile,$verbose,$max_set_size_per_node,$help,$tree,$label_array,
   $num_SNPs,$num_genomes,$node_list,$solution_array,$framesort,$start_node,
   $min_num_solns_per_node,$breadth_first_order,$reverse_order,
   $skip_input_check,$internal_nodes_only,$leaves_only,@analyze_nodes,
   $min_set_size_per_node,$low_memory_mode,$greedy_flag,$max_greedies,
   $quality_ratio,$equal_chance,$min_indep_solns_per_node,$start_cutoff_size);
my $overwrite_flag = 0;
my $quiet = 0;
my $preserve_args = [@ARGV];
my $DEBUG = 0;
my $greedy_only = 0;
my $scoring_function = 'original';

#Library for tree data structure
use tree;
my $tree = tree->new();

#Get the input options
use Getopt::Long;
GetOptions('t|treefile=s'            => \$treefile,
	   's|snpfile=s'             => \$snpfile,
	   'v|verbose!'              => \$verbose,
	   'q|quiet!'                => \$quiet,
	   'm|maxsize=s'             => \$max_set_size_per_node,
	   'z|minsize=s'             => \$min_set_size_per_node,
	   'h|help!'                 => \$help,
	   'p|start-cutoff-size=s'   => \$start_cutoff_size,
	   'n|minsolns=s'            => \$min_num_solns_per_node,
	   'j|minindeps=s'           => \$min_indep_solns_per_node,
	   'f|framesort!'            => \$framesort,
	   'l|low-memory-mode!'      => \$low_memory_mode,
	   'k|skip-input-check!'     => \$skip_input_check,
	   'b|breadth-first!'        => \$breadth_first_order,
	   'r|reverse-order!'        => \$reverse_order,
	   'i|internal-nodes-only!'  => \$internal_nodes_only,
	   'e|leaves-only!'          => \$leaves_only,
           'g|greedy!'               => \$greedy_flag,
	   'w|scoring-function=s'    => \$scoring_function, #original,worst
	   'o|skip-exhaustive!'      => \$greedy_only,
           'partial-suffix=s'        => \$partial_suffix,
	   'overwrite!'              => \$overwrite_flag,
           'x|max-greedies=s'        => \$max_greedies,
           'u|quality-ratio=s'       => \$quality_ratio,
	   'c|chance=s'              => \$equal_chance,
	   'a|start-node=s'          => \$start_node,
	   '<>'                      => sub {push(@analyze_nodes,$_[0])},
	   'debug:+'                 => \$DEBUG
	  );

#Set a max solution set size (i.e. number of SNPs) per phylogenetic tree branch
#because the running time other wise is:
#O(number_of_snps * (number_of_snps choose number_of_snps))
$max_set_size_per_node    = 3 unless($max_set_size_per_node =~ /^\d+$/);
$min_set_size_per_node    = 1 unless($min_set_size_per_node =~ /^\d+$/);
$min_num_solns_per_node   = 0 unless($min_num_solns_per_node =~ /^\d+$/);
$min_indep_solns_per_node = 0 unless($min_indep_solns_per_node =~ /^\d+$/);
$start_cutoff_size = ($start_cutoff_size =~ /^\d+$/ ?
		      $start_cutoff_size :
		      ($min_set_size_per_node > 3 ?
		       $min_set_size_per_node : 3));

#If the minimum number of independent solutions per node is 1, set it to 0 and
#change the minimum number of solutions per node to 1.  This saves work because
#independent solutions do not need to be calculated and is effectively the same
#outcome.  Plus, it utilizes the small solutions inside large solutions logic.
if($min_indep_solns_per_node == 1)
  {
    $min_indep_solns_per_node = 0;
    $min_num_solns_per_node   = 1;
  }

if($max_set_size_per_node < $min_set_size_per_node)
  {
    error("Your maximum solution size: [$max_set_size_per_node] is less than ",
	  "your minimum: [$min_set_size_per_node].");
    exit(1);
  }

if($min_set_size_per_node > 1)
  {
    warning("By not using the default minimum solution size (1), you may see ",
	    "smaller solutions repeated in all possible combinations.");
    sleep(2);
  }

#If they have asked for help
if($help)
  {
    help();
    exit(0);
  }

#If the required parameters are not supplied
if(!$snpfile || !$treefile)
  {
    #Print the usage statement and exit
    usage();
    exit(3);
  }

if($internal_nodes_only && $leaves_only)
  {
    error("You cannot use the [-i] and [-e] flags together!");
    usage();
    exit(4);
  }

if(($internal_nodes_only || $leaves_only) && $breadth_first_order)
  {
    warning("The breadth first ordering (flag [-b]) is being ignored because ",
	    "it doesn't work with the [-i] or [-e] flags.");
    $breadth_first_order = 0;
  }

print STDERR ("Running on cluster node: [$host].\n") if($cluster_run);

#Load and validate the SNP data (and set $snp_names and $genome_names arrays)
if(LoadSNPs($snp_names,$genome_names,$snpfile,$verbose,$snp_data_buffer,
	    $low_memory_mode))
  {
    help();
    exit(0);
  }
my $optimized_snps = optimizeSNPs($snp_names,$genome_names,$snp_data_buffer);

#Prepare output for partial solutions generated from greedy set building
if($greedy_flag && $partial_suffix ne '')
  {
    if(!$overwrite_flag && -e "$snpfile$partial_suffix")
      {error("File exists: [$snpfile$partial_suffix].  Greedy output going ",
	     "to STDERR")}
    else
      {
        if(scalar(@analyze_nodes))
          {$partial_suffix = '.' . $analyze_nodes[0] . $partial_suffix}
        unless(open(PRTL,">$snpfile$partial_suffix"))
          {
            error("Unable to open partial greedy set file for output ",
		  "[$snpfile$partial_suffix].  $!");
            exit(10);
          }
        select(PRTL);
        $|=1;
        select(STDOUT);
      }
  }

#Print out a list of equivalent SNPs to STDERR
my @tmp_equiv = map {join(',',map {$snp_names->[$_]} @$_)}
  grep {scalar(@$_) > 1} @$optimized_snps;
if(scalar(@tmp_equiv))
  {verbose("These SNPs are equivalent:\n\t[",
	   join("]\n\t[",@tmp_equiv),
	   "]\n")}
else
  {verbose("All SNPs appear to be unique.")}

verbose("Reading tree file: [$treefile].");

#Load and validate the phylogenetic tree data
$tree->treeThis($treefile);

verbose(($skip_input_check ? "Skipping tree check" : ""));

if(!$skip_input_check && CheckTreeNames($tree,$genome_names,$verbose))
  {
    error("Your SNP infile and phylogenetic tree infile's genomes don't ",
	  "match.  Please correct the files and try again.");
    exit(1);
  }

#Report the command line conditions for the run
print("#",getCommand(1),"\n");
print("#Run on cluster node: [$host].\n") if($cluster_run);

#Report the name of the SNP file used
print("#INPUT SNP FILE: [$snpfile]\n");

#Report the name of the tree file used
print("#INPUT TREE FILE: [$treefile]\n\n\n");

verbose("Initializing Solution Search.");

##
## Get all the nodes to analyze in the requested order
##

my($not_found);
if(scalar(@analyze_nodes))
  {
    verbose("Checking analysis nodes: [",join(',',@analyze_nodes),"].");

    $node_list = [map {
      my $nd = $tree->dfsKeySearch($_);
      if($nd->isNullNode())
	{
	  error("Node: [$_] was not found in the tree.");
	  $not_found = 1;
	}
      $nd;
    } @analyze_nodes];
    if($not_found)
      {exit(5)}
  }
#Get all the tree's nodes in BFS order
elsif($internal_nodes_only)
  {
    $node_list = $tree->getInternalNodesInDFSOrder();
    #Take off the root node
    shift(@$node_list);
  }
elsif($leaves_only)
  {$node_list = $tree->getLeafNodes()}
elsif($breadth_first_order)
  {
    $node_list = $tree->getAllNodesInBFSOrder();
    #Take off the root node
    shift(@$node_list);
  }
else
  {
    $node_list = $tree->getAllNodesInDFSOrder();
    #Take off the root node
    shift(@$node_list);
  }

verbose("Processing Tree.");

#Make the genomes numeric
if(ConvertGenomesInTreeToIndexes($genome_names,$tree,$verbose))
  {die("ERROR:SNPSTI.pl:Your SNP infile seems to be missing genomes present ",
       "in the tree.  Please correct the files and try again.\n")}

#Set the total number of SNPs and genomes
$num_SNPs    = scalar(@$snp_names);
my $num_optimal_snps = scalar(@$optimized_snps);
$num_genomes = scalar(@$genome_names);

if($min_set_size_per_node > $num_SNPs)
  {
    error("Your minimum solution size: [$min_set_size_per_node] is greater ",
	  "than the number of available SNPs in your data file: [$num_SNPs].");
    exit(6);
  }

if($max_set_size_per_node > $num_optimal_snps)
  {$max_set_size_per_node = $num_optimal_snps}

#Error check and handle greedy options
if(!$greedy_flag && ($max_greedies || $quality_ratio))
  {$greedy_flag = 1}
if(!defined($max_greedies))
  {$max_greedies = 20}
if(!defined($quality_ratio))
  {$quality_ratio = .1}
if($greedy_flag && $max_greedies == 0 && $quality_ratio == 0)
  {
    error("You cannot have both max-greedies (-x) and quality-ratio (-u) set ",
	  "to zero.  One must be non-zero.");
    exit(1);
  }
if($max_greedies !~ /^\d+$/ || $max_greedies > $num_SNPs)
  {
    if($max_greedies > $num_SNPs)
      {
	warning("max-greedies (-x) must be an integer between 1 and the ",
		"number of SNPs: [$num_SNPs].\nResetting max-greedies.");
	$max_greedies = $num_SNPs;
      }
    else
      {
	error("max-greedies (-x) must be an integer between 1 and the number ",
	      "of SNPs: [$num_SNPs].\nUnable to proceed.");
	exit(2);
      }
  }
if($quality_ratio !~ /^(0*\.\d+|1|0)$/ || $max_greedies > $num_SNPs)
  {
    error("max-greedies (-x) cannot be greater than the number of SNPs.  ",
	  "Resetting to maximum.");
    $max_greedies = $num_SNPs;

    #Note, I'm not turning off the greedy flag because the ultimate number of
    #greedies could be less due to the quality ratio
  }
if($greedy_flag)
  {
    verbose("Greedy_mode.\n");
    print("#Greedy_mode.\n");
  }

#Reverse the node order if requested
$node_list = [reverse(@$node_list)] if($reverse_order);

if(defined($start_node))
  {
    shift(@$node_list) while(scalar(@$node_list) &&
			     $node_list->[0]->getKey() ne $start_node);
    if(scalar(@$node_list) == 0)
      {
	error("The start node: [$start_node] was not found in the tree.");
	exit(1);
      }
  }

print("#Solutions for a node are ordered by SNP variability (i.e. amount of\n",
      "#evolutionary saturation) and frame position respectively so that\n",
      "#SNP sets that are good identifiers appear at the top.  A SNP set is\n",
      "#a good identifier if its value can tell you if it occurs under the\n",
      "#indicated phylogenetic tree node (1st column in the output).  The\n",
      "#ordering imposed here reduces the chance that the reported SNP set\n",
      "#will match an unknown by chance.\n\n\n");

verbose("Starting Search.");

my $greedy_snp_candidates       = [];
my $final_greedy_snp_candidates = [];
my($num_solns,$combos_so_far);
#For each internal node
foreach my $node (@$node_list)
  {
    verbose("\nDOING NODE: ",
	    ($node->isLeaf() ? $genome_names->[$node->getKey()] :
	     $node->getKey()));

    #Label the genomes below the current DFS node (and zero out all others)
    $label_array = LabelGenomes($num_genomes,$node);
    if(grep {$_ ne '1' && $_ ne '0'} @$label_array)
      {
	error("The label array has invalid values.  This is a bug in the ",
	      "program and is unresolvable.  Contact the developer.");
	exit(7);
      }

    #Report phylogenetic tree node location and the leaves present
    $solutions->{output}  = [];
    $solutions->{message} =
		    "#Solutions for the branch leading to node: [" .
		    ($node->isLeaf() ?
		     $genome_names->[$node->getKey()] :
		     $node->getKey()) .
		    "] containing these genomes (represented by 1s):\n";

    foreach my $genome (grep {$label_array->[$_]} (0..$#{$label_array}))
      {$solutions->{message} .= "#\t$genome_names->[$genome]\n"}

    $solutions->{message} .=
      "#NODE\tSNPs\tSIGNIFICANT LEAVES OF NUCLEOTIDE TREE (.ATGC-) " .
	"[PHYLOGENETIC TREE RELATIONSHIP: 1 = UNDER NODE, 0 = NOT UNDER " .
	  "NODE, _ = NOT IN TREE]\n";

    verbose("Optimizing search SNPs and genomes.");

    ##
    ## Collect the optimal SNPs that actually have any real SNP values for the
    ## labelled genomes (i.e. not dots)
    ##

    my $relevant_optimal_snps  = [];

    #Collect the genome indexes that are labelled
    my $labelled_genome_indexes =
      [grep {$label_array->[$_]} (0..$#{$label_array})];

    #Grab the SNPs that have any value for the labelled genomes
    @$relevant_optimal_snps =
      #Filter out SNPs that have no values for the labelled genomes
      grep {
	my $lab_gen_ind_ind = 0;
	while($lab_gen_ind_ind <= $#{$labelled_genome_indexes} &&
	      getSNP($snp_data_buffer,
		     $labelled_genome_indexes->[$lab_gen_ind_ind],
		     $optimized_snps->[$_]->[0]) eq '.')
	  {$lab_gen_ind_ind++}
	#Return whether or not all the values were dots
	#(all = false, not_all = true)
	$lab_gen_ind_ind <= $#{$labelled_genome_indexes};
      }
	(0..($num_optimal_snps - 1));

    verbose(0,
	    scalar(@$relevant_optimal_snps),
	    " out of ",
	    scalar(@$optimized_snps),
	    " SNPs considered.  Other SNPs were filtered out because ",
	    "they had all 'ignore' values for genomes under this node.");

    ##
    ## Collect the genomes that actually have real SNP values for any of the
    ## SNPs collected above
    ##

    #Eliminate any genomes that don't have any SNP values for the remaining
    #SNPs filtered above.  This should improve greedy score calculations
    #because uninvolved genomes won't dilute the scores.  Keep labelled
    #genomes whether or not they have have any SNP values
    my $remaining_snp_index = 0;
    my $relevant_genomes =
      [grep {
	my $grep_genome = $_;
	$remaining_snp_index = 0;
	while($remaining_snp_index <= $#{$relevant_optimal_snps} &&
	      getSNP($snp_data_buffer,
		     $grep_genome,
		     $optimized_snps
		     ->[$relevant_optimal_snps
			->[$remaining_snp_index]]->[0]) eq '.')
	  {$remaining_snp_index++}
	#Return whether or not all the values were dots
	#(all = false, not_all = true)
	$remaining_snp_index <= $#{$relevant_optimal_snps};
      }
       (0..$#{$genome_names})];

    verbose(0,
	    scalar(@$relevant_genomes),
	    " out of ",
	    scalar(@$genome_names),
	    " genomes considered.  Other genomes were filtered out ",
	    "because they had all 'ignore' values for the SNPs remaining ",
	    "from the previous filtering step.");

    #Now filter the label_array based on the retained genomes
    my $relevant_label_array = [map {$label_array->[$_]} @$relevant_genomes];

    if($greedy_flag)
      {
	verbose("Collecting greedy SNPs.");

	$final_greedy_snp_candidates = [];
	my $num_greedies     = 0;
	my $greedy_set_count = 0;
	my $greedy_sol_num   = 0;
        my $num_added        = 0;
	my $ratio            = 0;
	do
	  {
	    $num_added     = 0;
	    $ratio         = 0;
            my $prev_ratio = 0;
	    my $scores     = {};
	    $greedy_sol_num++;

	    while(1)
	      {
		$ratio = getNextGreedySNP($greedy_snp_candidates,
					  $relevant_optimal_snps,
					  $snp_data_buffer,
					  $relevant_label_array,
					  $equal_chance,
					  $snp_names,
					  $verbose,
					  $greedy_sol_num,
					  $relevant_genomes,
					  $scoring_function);

		if(!defined($ratio) || $ratio eq '')
		  {error("getNextGreedySNP returned an undefined ratio.")}

		$scores->{$greedy_snp_candidates->[-1]} = $ratio;

		$num_added++ unless($ratio == 1);
		$num_greedies++ unless($ratio == 1);  #Do this so we get all
                                                      #perfect SNPs plus enough
                                                      #to find alternatives
		last if($max_greedies <= $num_greedies ||
			($ratio - $prev_ratio) < $quality_ratio ||
			$ratio == 1 ||
			#I added the below check to stop greedy sets from
			#getting out of hand.  If I ever get around to fixing
			#the bug that causes greedy sets to think they're
			#improving when they're not when no SNPs that can
			#improve the previous solution exist, I should remove
			#this check
		        $num_added >= (2 * $max_set_size_per_node));
                $prev_ratio = $ratio;
	      }

	    $greedy_set_count++;
            my $greedymsg =
	      "Greedy set $greedy_set_count: \[" .
		join(',',
		     map {"[$snp_names->[$optimized_snps->[$_]->[0]]]:" .
			    "($scores->{$_})"}
		     @$greedy_snp_candidates) .
		       "].\n";
	    verbose(1,$greedymsg);
            print PRTL $greedymsg if($partial_suffix ne '');

	    push(@$final_greedy_snp_candidates,@$greedy_snp_candidates);
	    $greedy_snp_candidates = [];
	  }
	    while(scalar(@$relevant_optimal_snps) &&
		  ($num_added > 0 || ($num_added == 0 && $ratio == 1)) &&
		  ($num_greedies < $max_greedies || $max_greedies == 0));

	print STDERR ("DEBUG: ",scalar(@$relevant_optimal_snps),
		      " && ($num_added > 0 || ($num_added == 0 && $ratio == ",
		      "1)) && ($num_greedies < $max_greedies || ",
		      "$max_greedies == 0)\n")
	  if($DEBUG);

	#print STDERR ("TEST: ",scalar(@$relevant_optimal_snps)," && (($num_greedies < $max_greedies || $max_greedies == 0) && ($num_added > 0 || $quality_ratio == 0))\n") if ($DEBUG);


	#I know there are places where SNP order is important.  I can't
	#remember where that is though, so I'm going to sort the greedies here
	#just to be safe.
	@$final_greedy_snp_candidates =
	  sort {$a <=> $b} @$final_greedy_snp_candidates;

        my $greedymsg = "Final Greedy set of " . scalar(@$final_greedy_snp_candidates) . " SNPs: [" .
                join(',',
                     map {$snp_names->[$optimized_snps->[$_]->[0]]}
                     @$final_greedy_snp_candidates) .
                "].\n";
	verbose($greedymsg);
        print PRTL $greedymsg if($partial_suffix ne '');

	if($greedy_only)
	  {exit(0)}

	verbose("Beginning exhaustive search of the greedy SNPs.");
      }

    verbose("SELECTED ANALYSIS SNPS:\n\t",
	    join("\n\t",
		 map {$snp_names->[$optimized_snps->[$_]->[0]]}
		 ($greedy_flag ?
		  (@$final_greedy_snp_candidates) :
		  (@$relevant_optimal_snps))),
	    "\n");
    verbose("SELECTED ANALYSIS GENOMES:\n\t",
	    join("\n\t",map {$genome_names->[$_]} @$relevant_genomes),
	    "\n");

    #Clear out the current and solution sets for each new dfs node to start
    #searching from the beginning
    #If current_set turns out to be a solution, it will be pushed onto the
    #solution set array
    my $candidate_set = [];
    my $num_indep_solns = 0;
    my(@current_set,@solution_sets);
    #Keep track of small solution sets so I can skip them when they're in
    #larger solutions
    my $small_sets = [];
    foreach my $set_size ($min_set_size_per_node..$max_set_size_per_node)
      {
	#Keep track of the new small solution sets generated so I can add them
	#to the small_sets at the end of this loop
	my $new_small_sets = [];

	verbose("\nDOING SET SIZE: $set_size");

	$num_solns_per_size = 0;

	verbose("DEBUG: Call to GetNextCombo([@current_set],$set_size,",
		scalar(@$final_greedy_snp_candidates),")") if($DEBUG > 1);

	#While an unseen combination of SNPs based on n choose r still exists
	#at the current set size (n = $num_SNPs, r = $set_size)
	while(GetNextCombo(\@current_set,
			   $set_size,
			   ($greedy_flag ?
			    scalar(@$final_greedy_snp_candidates) :
			    scalar(@$relevant_optimal_snps))))
	  {
	    $candidate_set = [];

	    if($greedy_flag)
	      {
		#create a candidate solution using the values in the
		#@current_set and at the indexes indicated in the final greedy
		#snp candidates
		foreach my $greedy_index (@current_set)
		  {push(@$candidate_set,
			$final_greedy_snp_candidates->[$greedy_index])}
	      }
	    else
	      {
		foreach my $optimal_index (@current_set)
		  {push(@$candidate_set,
			$relevant_optimal_snps->[$optimal_index])}
	      }

	    #Convert the optimal SNP indexes to real SNP indexes
	    @$candidate_set = map {$optimized_snps->[$_]->[0]} @$candidate_set;

	    if($verbose)
	      {
		$combos_so_far++;
		verbose(#1,
			"Doing combination: [",
			join(',',map {$snp_names->[$_]} @$candidate_set),
			"] Solutions found: $num_solns_per_size");
	      }

	    next if($min_num_solns_per_node != 1 && scalar(@$small_sets) &&
		    smallSolutionInside($candidate_set,$small_sets));

	    #Clear out the solution array.  The solution array is an array of
	    #all the genome labels at the leaves of the solution tree.  The
	    #solution tree is a 6 degree tree with branches (.ATGC-) that lead
	    #to a genome label at each leaf (0 = not in subtree, 1 = in
	    #subtree, _ = This SNP combination doesn't occur in any of the
	    #genomes).  Each level of the six degree tree is a SNP from the
	    #current_set
	    $solution_array = [];

	    #If current_set is a solution set
	    if(isSolution($candidate_set,
			  $snp_data_buffer,
			  $relevant_genomes,
			  $label_array,
			  $solution_array))
	      {
		$num_solns_per_size++;

		#Report the node the solution is for
		push(@{$solutions->{output}},
		     ($node->isLeaf() ?
		      $genome_names->[$node->getKey()] :
		      $node->getKey()) . "\t");
		#Report the SNPs in the solution (i.e. 6 degree tree levels)
		foreach my $snp (@$candidate_set)
		  {
		    $all_snps_used->{$snp_names->[$snp]} = 1;
		    $solutions->{output}->[-1] .= "$snp_names->[$snp] ";
		  }
		#Report the leaves of the six degree tree so that the SNP
		#values can be determined
		$solutions->{output}->[-1] .= "\t" .
		    join(' ',@$solution_array) . "\n";
		push(@solution_sets,[@$candidate_set]);

		##
		## Add equivalent solutions
		##

		#Inititialize the equivalent solutions
		my $equivalent_candidate_set = [];
		#Let the first one pass because we already have it (above)
		GetNextIndepCombo($equivalent_candidate_set,
				  [map
				   {scalar(@{$optimized_snps
					       ->[($greedy_flag ?
						   $final_greedy_snp_candidates
						   ->[$_] :
						   $relevant_optimal_snps
						   ->[$_])]})}
				   @current_set]);

		#verbose("ALL ZEROES: EQUIVALENT SOLUTION TO: [",
		#	join(' ',map {$snp_names->[$_]} @$candidate_set),
		#	"]: [",
		#	join(' ',map {$snp_names->[$_]}
		#	    map {$optimized_snps->[$final_greedy_snp_candidates
		#				    ->[$current_set[$_]]]
		#		    ->[$equivalent_candidate_set->[$_]]}
		#	     (0..(scalar(@$equivalent_candidate_set) - 1))),
		#	"].");

		while(GetNextIndepCombo($equivalent_candidate_set,
					[map
					 {scalar(@{
					   $optimized_snps
					     ->[($greedy_flag ?
						 $final_greedy_snp_candidates
						 ->[$_] :
						 $relevant_optimal_snps
						 ->[$_])]})}
					 @current_set]))
		  {
		    #Convert to real SNP indexes
		    #  @current_set contains the indexes into $optimized_snps
		    #    for the "equivalent arrays"
		    #  $equivalent_candidate_set contains indexes into the
		    #    "equivalent arrays"
		    #  The indexes into @current_set and
		    #    $equivalent_candidate_set correspond such that the two
		    #    indexes into both levels of $optimized_snps can be
		    #    accessed with the same index into @current_set and
		    #    $equivalent_candidate_set
		    my $equivalent_solution =
		      [map {$optimized_snps->[($greedy_flag ?
					       $final_greedy_snp_candidates
					       ->[$current_set[$_]] :
					       $relevant_optimal_snps
					       ->[$current_set[$_]])]
			      ->[$equivalent_candidate_set->[$_]]}
		       (0..(scalar(@$equivalent_candidate_set) - 1))];

		    #verbose("EQUIVALENT SOLUTION TO: [",join(' ',map {$snp_names->[$_]} @$candidate_set),"]: [",join(' ',map {$snp_names->[$_]} @$equivalent_solution),"].");

		    $solution_array = [];

		    if(!isSolution($equivalent_solution,
				   $snp_data_buffer,
				   $relevant_genomes,
				   $label_array,
				   $solution_array))
		      {error("Equivalent solution failed!")}

		    $num_solns_per_size++;

		    #Report the node the solution is for
		    push(@{$solutions->{output}},
			 ($node->isLeaf() ?
			  $genome_names->[$node->getKey()] :
			  $node->getKey()) . "\t");
		    #Report the SNPs in the soln. (i.e. 6 degree tree levels)
		    foreach my $snp (@$equivalent_solution)
		      {
			$all_snps_used->{$snp_names->[$snp]} = 1;
			$solutions->{output}->[-1] .= "$snp_names->[$snp] ";
		      }
		    #Report the leaves of the six degree tree so that the SNP
		    #values can be determined
		    $solutions->{output}->[-1] .= "\t" .
		      join(' ',@$solution_array) . "\n";
		    push(@solution_sets,[@$equivalent_solution]);
		  }

		#Push this set onto the new_small_sets array if we're going to
		#be moving up to the next set size to look for more solutions
		push(@$new_small_sets,[@$candidate_set])
		  if($min_num_solns_per_node != 1 &&
		     $set_size != $max_set_size_per_node &&
		     (scalar(@solution_sets) <= $min_num_solns_per_node ||
		      $min_num_solns_per_node == 0));

		$num_indep_solns = numIndepSolns(@solution_sets);

		if($start_cutoff_size == 0 || $set_size >= $start_cutoff_size)
		  {
		    if(scalar(@solution_sets) >= $min_num_solns_per_node &&
		       $min_num_solns_per_node != 0)
		      {last}

		    if($min_indep_solns_per_node != 0 &&
		       $num_indep_solns >= $min_indep_solns_per_node)
		      {last}
		  }
	      }

	    verbose("DEBUG: Call to GetNextCombo([@current_set],$set_size,",scalar(@$final_greedy_snp_candidates),")") if($DEBUG > 1);
	  }

	#This last update will be useful if the last combination is a solution
	verbose(1,
		"Doing combination: [",
		join(',',map {$snp_names->[$_]} @$candidate_set),
		"] Solutions found: $num_solns_per_size");

	if($start_cutoff_size == 0 || ($set_size + 1) >= $start_cutoff_size)
	  {
	    #If solutions were found at the current set size, don't bother
	    #looking for solutions at larger sizes and jump out of the loop
	    last if(scalar(@solution_sets) >= $min_num_solns_per_node &&
		    $min_num_solns_per_node != 0);
	    last if($min_indep_solns_per_node != 0 &&
		    $num_indep_solns >= $min_indep_solns_per_node);
	  }

	#If solutions were found at this set size, add them to the small_sets
	#so they can be skipped at subsequent set sizes
	push(@$small_sets,@$new_small_sets) if(scalar(@$new_small_sets));
      }

    #Print the sorted solutions
    printSortedResults($solutions,$framesort);

    #Report the number of solutions found and the time taken
    verbose("\nIt took ",
	    (time() - $time),
	    " seconds to get to & finish this node: [",
	    ($node->isLeaf() ?
	     $genome_names->[$node->getKey()] :
	     $node->getKey()),
	    "].  ",
	    (scalar(@solution_sets) ?
	     join('',("Smallest solution size: [",
		      scalar(@{$solution_sets[0]}),
		      " SNPs] using a maximum set size of ",
		      "[$max_set_size_per_node] SNPs per solution and a ",
		      "minimum solution size of: [$min_set_size_per_node].")) :
	     ''));

    #Put a hard return between sets of node solutions
    print("\n");
  }

close(PRTL) if($greedy_flag && $partial_suffix ne '');

print("#TOTAL SNPS USED IN ALL SOLUTIONS (",
      scalar(keys(%$all_snps_used)),
      "):\n#\t",
      join("\n#\t",sort {$a <=> $b} keys(%$all_snps_used)),
      "\n");

#Report the total running time if in verbose mode
verbose("Total Running Time: ",(time() - $time)," seconds.");


#isSolution Subroutine
#This subroutine is recursive.  It determines whether a proposed set of SNPS
#sent in (based on their values in the snp_data sent in) can uniquely identify
#the labelled genomes in the label_array sent in.  It stores the labels in a
#solution_array representing the leaves of a 6-degree tree where each node
#has branches in this order: . (none), A, T, G, C, and - (alignment gap).
#Another generic order can be superimposed on this representing 5 evolutionary
#states: 1, 2, 3, 4, and 5.  An example of an evolutionary state would be the
#loss or acquisition of a piece of DNA such as a gene.  These two
#representations are not allowed to be mixed.  in other words, one column of
#SNP data cannot have bases (or gaps) mixed with generic states (numbers).
#This mix is not error checked for here in this subroutine.  See LoadSNPs.  The
#dot character is present to support multi-locus alignments where a number of
#genomes may simply not contain the gene with a particular SNP used in the
#analysis.  but since the lack of a result is not dependable, solutions from
#genomes that are separated on the basis that they have no SNP value are
#compared for consistency to those that did have the SNP.  In other words the
#lack of a SNP result on an array can still yield an identification, but
#solutions which differ in what they identify because of the lack of a SNP (as
#opposed to the failure of probes made for a real SNP) are eliminated.
sub isSolution
  {
    #Break off the first snp in the array and store the rest in the
    #proposed_solution which will be sent in a recursive call
    my($snp,$proposed_solution);
    ($snp,@$proposed_solution) = @{$_[0]};

    my $snp_data_buffer        = $_[1];  #Array of SNP strings
    my $genome_indexes         = $_[2];  #Array of genome indexes into the SNP
                                         #data buffer
    my $label_array            = $_[3];  #Array of genome labels indexed by
                                         #genome
    my $solution_array         = $_[4];  #Leaves of a [.ATGC-] 6-degree tree
                                         #which stores labels.  Levels of the
                                         #tree represent SNPs in the entire
                                         #proposed solution
    my $skip_empty             = $_[5];  #Internal use only.  DO NOT SUPPLY.
                                         #When all the wells are empty, we can
                                         #skip this recursive call after adding
                                         #the necessary solution spacers

    #my($framesort_warning): required global variable
    my $answer = 1;  #This indicates we've found an answer

    if($skip_empty)
      {
	push(@$solution_array,
	     split('',('_' x (6 ** (scalar(@$proposed_solution) + 1)))));
	return($answer);
      }

    #The solution array is an empty array sent in.  It is populated with the
    #leaves of a 5-degree tree.  The branches are nucleotides (.ATGC- or
    #.12345) from left to right.  The number of levels corresponds to the
    #number of SNPs in the solution (left to right in the SNP solution array
    #corresponds to top down in the tree).  The tree can be reconstructed from
    #the SNPs, the .ATGC- (.12345) order, and the solution array.  The values
    #at the leaves are the labels (i.e. whether or not a genome is in the
    #phylogenetic sub-tree).  The important information is the values of the
    #SNPs when they lead to the subtree leaves.

    #Initialize variables local to this recursive call
    my $genome_types    = []; #Indicates what label a genome well contains
    my $genome_wells    = [[],[],[],[],[],[]];  #Contains genome indexes based
                                                #on the current SNP value
    my($matched);
    #For each genome
    foreach my $genome (sort {$label_array->[$b] <=> $label_array->[$a]}
			@$genome_indexes)
      {
	my $snp_val = getSNP($snp_data_buffer,$genome,$snp);

	$matched = 0;

	#If this is the first call and this is a labelled genome
	if(!defined($skip_empty) && $label_array->[$genome])
	  {
	    my $give_up = 1;

	    #If the SNP is totally ambiguous, look ahead to see if this search
	    #will be futile (i.e. all SNPs for this labelled genome are
	    #ambiguous)
	    my $snp_val = getSNP($snp_data_buffer,$genome,$snp);
	    if($snp_val !~ /^\.$/i)
	      {$give_up = 0}
	    elsif(scalar(@$proposed_solution))
	      {
		#Foreach future SNP value for the current genome
		foreach my $snp_val (map {getSNP($snp_data_buffer,$genome,$_)}
				     @$proposed_solution)
		  {
		    #If the SNP value is not entirely ambiguous
		    if($snp_val !~ /^\.$/i)
		      {
			#Decide not to give up and move on
			$give_up = 0;
			last;
		      }
		  }
	      }

	    return(0) if($give_up);
	  }

	#If the first snp value from the proposed solution contains a dot
	#(i.e. totally ambiguous or ignored SNP)
	if($snp_val eq '.')
	  {
	    $matched = 1;

	    #If the well type is not defined, give it this genome's label
	    if($genome_types->[0] eq '')
	      {$genome_types->[0] = $label_array->[$genome]}
	    #Else if it has a label and it doesn't match the label of the
	    #current genome, set the answer to false
	    elsif($genome_types->[0] != $label_array->[$genome])
	      {$answer = 0}

	    if(!defined($skip_empty) &&
	       scalar(@$proposed_solution) == 0 &&
	       $label_array->[$genome])
	      {
		error("The first call to isSolution allowed a totally ",
		      "ambiguous proposed solution to get through.  This ",
		      "should not have happened because these situations are ",
		      "supposed to be filtered out.  The SNP that got here ",
		      "is at index: [$snp] and genome index: [$genome] with ",
		      "value: [.].");
		exit(9);
	      }

	    #Push the current genome's SNP data and labels into the pseudo-well
	    push(@{$genome_wells->[0]},$genome);
	  }
	else
	  {
	    #If the first snp value from the proposed solution contains an A or
	    #1 for this genome
	    if($snp_val =~ /^[a1dhvrmwnx]$/i)
	      {
		$matched = 1;

		#If the genome well for As does not yet contain a label, label
		#it
		if($genome_types->[1] eq '')
		  {$genome_types->[1] = $label_array->[$genome]}
		#Else if it has a label and it doesn't match the label of the
		#current genome, set the answer to false
		elsif($genome_types->[1] != $label_array->[$genome])
		  {$answer = 0}

		#Push the current genome's SNP data and labels into the A well
		push(@{$genome_wells->[1]},$genome);
	      }
	    #If the first snp value from the proposed solution contains a T or
	    #2 for this genome
	    if($snp_val =~ /^[t2bdhykwnx]$/i)
	      {
		$matched = 1;

		#If the genome well for Ts does not yet contain a label, label
		#it
		if($genome_types->[2] eq '')
		  {$genome_types->[2] = $label_array->[$genome]}
		#Else if it has a label and it doesn't match the label of the
		#current genome, set the answer to false
		elsif($genome_types->[2] != $label_array->[$genome])
		  {$answer = 0}

		#Push the current genome's SNP data and labels into the T well
		push(@{$genome_wells->[2]},$genome);
	      }
	    #If the first snp value from the proposed solution contains a G or
	    #3 for this genome
	    if($snp_val =~ /^[g3bdvrksnx]$/i)
	      {
		$matched = 1;

		#If the genome well for Gs does not yet contain a label, label
		#it
		if($genome_types->[3] eq '')
		  {$genome_types->[3] = $label_array->[$genome]}
		#Else if it has a label and it doesn't match the label of the
		#current genome, set the answer to false
		elsif($genome_types->[3] != $label_array->[$genome])
		  {$answer = 0}

		#Push the current genome's SNP data and labels into the G well
		push(@{$genome_wells->[3]},$genome);
	      }
	    #If the first snp value from the proposed solution contains a C or
	    #4 for this genome
	    if($snp_val =~ /^[c4bhvymsnx]$/i)
	      {
		$matched = 1;

		#If the genome well for Cs does not yet contain a label, label
		#it
		if($genome_types->[4] eq '')
		  {$genome_types->[4] = $label_array->[$genome]}
		#Else if it has a label and it doesn't match the label of the
		#current genome, set the answer to false
		elsif($genome_types->[4] != $label_array->[$genome])
		  {$answer = 0}

		#Push the current genome's SNP data and labels into the C well
		push(@{$genome_wells->[4]},$genome);
	      }
	    #If the first snp value from the proposed solution contains a gap
	    #(-) or 5 for this genome
	    if($snp_val =~ /^[\-5]$/i)
	      {
		$matched = 1;

		if(!$framesort_warning && $framesort &&
		   $snp_val eq '-')
		  {
		    warning("WARNING:SNPSTL.pl:isSolution:Your SNPs have a ",
			    "gap character (-).  Framesort will not work ",
			    "properly.");
		    $framesort_warning = 1;
		  }

		#If the genome well for gaps does not yet contain a label,
		#label it
		if($genome_types->[5] eq '')
		  {$genome_types->[5] = $label_array->[$genome]}
		#Else if it has a label and it doesn't match the label of the
		#current genome, set the answer to false
		elsif($genome_types->[5] != $label_array->[$genome])
		  {$answer = 0}

		#Push the current genome's SNP data and labels into the dot (.)
		#well
		push(@{$genome_wells->[5]},$genome);
	      }
	  }

	#If the SNP character is erroneous
	if(!$matched)
	  {
	    error("Bad SNP character in input file for genome: ",
		  "[$genome_names->[$genome]] and SNP: [$snp_names->[$snp]]: ",
		  "[$snp_val].\n");
	  }
      }

    #If this is the first call and all the "real" wells are all empty (i.e. not
    #including the pseudo-well at index 5 becuase we shouldn't run into a SNP
    #that has NO real values)
    if(!defined($skip_empty) &&
       ((scalar(@{$genome_wells->[0]}) == 0 &&
	 scalar(@{$genome_wells->[1]}) == 0 &&
	 scalar(@{$genome_wells->[2]}) == 0 &&
	 scalar(@{$genome_wells->[3]}) == 0 &&
	 scalar(@{$genome_wells->[4]}) == 0 &&
	 scalar(@{$genome_wells->[5]}) == 0) ||
	(scalar(@$genome_types) == 0)))
      {
	#ERROR
	error("The first call to isSolution did not find any data for ",
	      "SNP[$snp] in the buffer of size: [",
	      scalar(@$genome_indexes),
	      "]!  Either there is a bug in the program or your SNP data ",
	      "file is not correctly formatted.");
	exit(8);
      }

    #If we're not at the end of the solution
    if(scalar(@$proposed_solution))
      {
	#Make a recursive call for each well and return their AND'ed result
	#For the fifth argument, supply a boolean value indicating whether
	#there are any genomes in the wells being sent
	return(#Call the 6th well first so that if it doesn't resolve, I don't
	       #waste memory

	       isSolution($proposed_solution,
			  $snp_data_buffer,
			  $genome_wells->[0],
			  $label_array,
			  $solution_array,
			  scalar(@{$genome_wells->[0]}) == 0) &&
	       isSolution($proposed_solution,
			  $snp_data_buffer,
			  #If there are genomes in the real well and in the
			  #pseudo-well, then add the genomes from the pseudo
			  #well
			  (scalar(@{$genome_wells->[1]}) &&
			   scalar(@{$genome_wells->[0]}) ?
			   [@{$genome_wells->[1]},@{$genome_wells->[0]}] :
			   $genome_wells->[1]),
			  $label_array,
			  $solution_array,
			  scalar(@{$genome_wells->[1]}) == 0) &&
	       isSolution($proposed_solution,
			  $snp_data_buffer,
			  #If there are genomes in the real well and in the
			  #pseudo-well, then add the genomes from the pseudo
			  #well
			  (scalar(@{$genome_wells->[2]}) &&
			   scalar(@{$genome_wells->[0]}) ?
			   [@{$genome_wells->[2]},@{$genome_wells->[0]}] :
			   $genome_wells->[2]),
			  $label_array,
			  $solution_array,
			  scalar(@{$genome_wells->[2]}) == 0) &&
	       isSolution($proposed_solution,
			  $snp_data_buffer,
			  #If there are genomes in the real well and in the
			  #pseudo-well, then add the genomes from the pseudo
			  #well
			  (scalar(@{$genome_wells->[3]}) &&
			   scalar(@{$genome_wells->[0]}) ?
			   [@{$genome_wells->[3]},@{$genome_wells->[0]}] :
			   $genome_wells->[3]),
			  $label_array,
			  $solution_array,
			  scalar(@{$genome_wells->[3]}) == 0) &&
	       isSolution($proposed_solution,
			  $snp_data_buffer,
			  #If there are genomes in the real well and in the
			  #pseudo-well, then add the genomes from the pseudo
			  #well
			  (scalar(@{$genome_wells->[4]}) &&
			   scalar(@{$genome_wells->[0]}) ?
			   [@{$genome_wells->[4]},@{$genome_wells->[0]}] :
			   $genome_wells->[4]),
			  $label_array,
			  $solution_array,
			  scalar(@{$genome_wells->[4]}) == 0) &&
	       isSolution($proposed_solution,
			  $snp_data_buffer,
			  #If there are genomes in the real well and in the
			  #pseudo-well, then add the genomes from the pseudo
			  #well
			  (scalar(@{$genome_wells->[5]}) &&
			   scalar(@{$genome_wells->[0]}) ?
			   [@{$genome_wells->[5]},@{$genome_wells->[0]}] :
			   $genome_wells->[5]),
			  $label_array,
			  $solution_array,
			  scalar(@{$genome_wells->[5]}) == 0));
      }

    #The following code only executes at leaves of the 6-degree [.ATGC-] (or
    #.12345) tree
    #Mark unlabelled leaves of the 5-degree tree
    $genome_types->[0] = '_' unless($genome_types->[0] =~ /\S/);
    $genome_types->[1] = '_' unless($genome_types->[1] =~ /\S/);
    $genome_types->[2] = '_' unless($genome_types->[2] =~ /\S/);
    $genome_types->[3] = '_' unless($genome_types->[3] =~ /\S/);
    $genome_types->[4] = '_' unless($genome_types->[4] =~ /\S/);
    $genome_types->[5] = '_' unless($genome_types->[5] =~ /\S/);

    #Push the leaves onto the solution_array (this happens in DFS order)
    push(@$solution_array,@$genome_types);

    #Return the answer
    return($answer);
  }


#This subroutine takes a current Combination, the size of the combination set,
#and the pool size.  It returns a new combination that hasn't been returned
#before.  This is an n_choose_r iterator.  It returns true if it was able to
#create an unseen combination, false if there are no more/
sub GetNextCombo
  {
    #Read in parameters
    my $combo     = $_[0];  #An Array of numbers
    my $set_size  = $_[1];  #'r' from (n choose r)
    my $pool_size = $_[2];  #'n' from (n choose r)

    #return false and report error if the combo is invalid
    if(@$combo > $pool_size)
      {
	error("Combination cannot be bigger than the pool size!");
	return(0);
      }

    #Initialize the combination if it's empty (first one) or if the set size
    #has increased since the last combo
    if(scalar(@$combo) == 0 || scalar(@$combo) != $set_size)
      {
	verbose("DEBUG: Initializing combo.") if ($DEBUG > 1);
	#Empty the combo
	@$combo = ();
	#Fill it with a sequence of numbers starting with 0
        foreach(0..($set_size-1))
          {push(@$combo,$_)}
	#Return true
        return(1);
      }

    #Define an upper limit for the last number in the combination
    my $upper_lim = $pool_size - 1;
    my $cur_index = $#{$combo};

    verbose("DEBUG: Upper limit: $upper_lim.\nCurrent Index: $cur_index") if ($DEBUG > 1);
    #Increment the last number of the combination if it is below the limit and
    #return true
    if($combo->[$cur_index] < $upper_lim)
      {
	verbose("DEBUG: Incrementing value at index $cur_index because ($combo->[$cur_index] < $upper_lim).") if ($DEBUG > 1);
        $combo->[$cur_index]++;
        return(1);
      }

    #While the current number (starting from the end of the combo and going
    #down) is at the limit and we're not at the beginning of the combination
    while($combo->[$cur_index] == $upper_lim && $cur_index >= 0)
      {
	#Decrement the limit and the current number index
        $upper_lim--;
        $cur_index--;
	verbose("DEBUG: Upper limit: $upper_lim.\nCurrent Index: $cur_index")
	  if ($DEBUG > 1);
      }

    verbose("DEBUG: Incrementing value at index $cur_index.") if ($DEBUG > 1);

    #Increment the last number out of the above loop
    $combo->[$cur_index]++;

    #For every number in the combination after the one above
    foreach(($cur_index+1)..$#{$combo})
      {
	verbose("DEBUG: Setting subsequent values.") if ($DEBUG > 1);
	#Set its value equal to the one before it plus one
	$combo->[$_] = $combo->[$_-1]+1;
      }

    #If we've exceded the pool size on the last number of the combination
    if($combo->[-1] > $pool_size)
      {
	verbose("DEBUG: Ending because we finished the pool size: ($combo->[-1] > $pool_size).") if ($DEBUG > 1);
	#Return false
	return(0);
      }

    #Return true
    return(1);
  }


#This sub has a "bag" for each position being incremented.  In other words, the
#$pool_size is an array of values equal in size to the $set_size.  So it yields
#all combinations where characters may be repeated in each slot.
sub GetNextIndepCombo
  {
    #Read in parameters
    my $combo      = $_[0];  #An Array of numbers
    my $pool_sizes = $_[1];  #An Array of numbers indicating the range for each
                             #position in $combo

    if(ref($combo) ne 'ARRAY' ||
       scalar(grep {/\D/} @$combo))
      {
	error("The first argument must be an array reference to an array of ",
	      "integers.");
	return(0);
      }
    elsif(ref($pool_sizes) ne 'ARRAY' ||
	  scalar(grep {/\D/} @$pool_sizes))
      {
	error("The second argument must be an array reference to an array of ",
	      "integers.");
	return(0);
      }

    my $set_size   = scalar(@$pool_sizes);

    #Initialize the combination if it's empty (first one) or if the set size
    #has changed since the last combo
    if(scalar(@$combo) == 0 || scalar(@$combo) != $set_size)
      {
	#Empty the combo
	@$combo = ();
	#Fill it with zeroes
        @$combo = (split('','0' x $set_size));
	#Return true
        return(1);
      }

    my $cur_index = $#{$combo};

    #Increment the last number of the combination if it is below the pool size
    #(minus 1 because we start from zero) and return true
    if($combo->[$cur_index] < ($pool_sizes->[$cur_index] - 1))
      {
        $combo->[$cur_index]++;
        return(1);
      }

    #While the current number (starting from the end of the combo and going
    #down) is at the limit and we're not at the beginning of the combination
    while($combo->[$cur_index] == ($pool_sizes->[$cur_index] - 1) &&
	  $cur_index >= 0)
      {
	#Decrement the current number index
        $cur_index--;
      }

    #If we've gone past the beginning of the combo array
    if($cur_index < 0)
      {
	@$combo = ();
	#Return false
	return(0);
      }

    #Increment the last number out of the above loop
    $combo->[$cur_index]++;

    #For every number in the combination after the one above
    foreach(($cur_index+1)..$#{$combo})
      {
	#Set its value equal to 0
	$combo->[$_] = 0;
      }

    #Return true
    return(1);
  }



#This sub takes a file of SNP data, sets names arrays for SNPs and genomes, and
#returns a 2D array of SNP data indexed on genome and SNP respectively.  See
#`SNPSTI.pl -h` for a description and example of the input file format.
sub LoadSNPs
  {
    #I need to identify columns with evolutionary states 12345 so that I don't use frame sort on them.  I also need to make sure the states 12345 aren't mixed with other states (except ambiguous ones are OK)

    #Use a strict environment
    use strict;

    #Read in parameters
    my $snp_names       = $_[0];  #A declared empty array from main
    my $genome_names    = $_[1];  #A declared empty array from main
    my $file            = $_[2];  #SNP data file name
    my $verbose         = $_[3];
    my $snp_data_buffer = $_[4];
    my $low_memory_mode = $_[5];

    #Make sure we can open the SNP data file
    unless(open(FILE,$file))
      {
	error("LoadSNPs:Unable to open file: [$file].\n$!");
	return(1);
      }

    #Initialize and declare variables
    my $line = 0;
    my $snp_names_done = 0;
    my($last_size,$tmp,$curline,$score_hash);

    #For each line of the SNP data file
    while($curline = <FILE>)
      {
	#Eliminate the hard return
        chomp($curline);

	#Skip empty and commented lines
        next if($curline =~ /^\#/ || $curline !~ /\S/);

	#If we haven't processed the first line of SNP names yet
	unless($snp_names_done)
	  {
	    #Error check the first line
	    my @errors =
	      (grep {$_ !~ /^(\D*\d+\D*|\d+\D.*)$/} split(/\s+/,$curline));
	    if($framesort && scalar(@errors))
	      {
               error("Invalid SNP names: [@errors] on the first line: ",
		     "[$curline].\n",
		     "In order to sort results by frame position, the SNP ",
		     "names in your data file must have only one number ",
		     "representing the SNP sequence position relative to the ",
		     "start codon (starting from 1).  There may not be any ",
		     "other numbers.");
		return(2);
	      }

	    #Get rid of the leading white space on the line
	    $curline =~ s/^\s+//;

	    #Split the names on white space
	    @$snp_names = split(/\s+/,$curline);

	    #Mark the SNP names as done
	    $snp_names_done = 1;

	    #Skip the rest for this iteration
	    next;
	  }

	verbose(1,'Reading SNP Data row ',($line + 1),'.')
	  if(($line + 1) % 10 == 0);

	#Separate the genome name from the SNP data by the first tab
        #We do this because a comment with spaces is allowed before
        #the SNP names, as in the node names below
	($genome_names->[$line],$tmp) =
	  ($curline =~ /^([^\t]*?)\s*\t+([^\t]*.*)$/g);

	#Eliminate leading and trailing white space from the data
	$tmp =~ s/^\s+//;
	$tmp =~ s/\s+$//;

        my @checklens = grep {length($_) != 1} split(/\s+/,$tmp);
        if(scalar(@checklens))
          {
            error("Invalid SNP value(s): [@checklens] for genome $genome_names->[$line].");
          }

	$tmp =~ s/\s+//g;

	#Score the genomes based on number of ambiguous characters
	my $tmp_score = 0;
	$tmp_score++ while($tmp =~ /[nx\?\.]/g);
	push(@{$score_hash->{$tmp_score}},$line);

	#If we're going to buffer the data, store the first few SNP columns
	if($low_memory_mode)
	  {
	    $tmp =~ s/\s//g;
	    ${$snp_data_buffer->[$line]} = $tmp;
	  }
	else
	  {$snp_data_buffer->[$line] = [split('',$tmp)]}

	#Error check the number of columns
        if($last_size != length($tmp) && defined($last_size))
	  {
            error("Genome: [$genome_names->[$line]] on line $line has a different number of SNPs: [",
		  length($tmp),
		  "] than previous lines: [$last_size]!");
	    return(3);
	  }
	elsif($snp_names_done != 2 &&
	      scalar(@$snp_names) != length($tmp))
	  {
	    error("Genome [$genome_names->[$line]] on line [$line] doesn't have the same number of ",
		  "columns: [",
		  length($tmp),
		  "] as the column names (SNP (names and) positions): [",
		  scalar(@$snp_names),
		  "]!");
	    return(4);
	  }
	else
	  {
	    #SNP names had the correct number of columns, so mark the name
	    #error check as done
	    $snp_names_done = 2;
	  }

	#Store the last number of columns
        $last_size = length($tmp);

	#Increment the line number
        $line++;
      }
    close(FILE);

    #Sort the genomes based on score so that isSolution will give up on
    #pointless searches as early as possible
    my(@sorted_data,@sorted_genome_names);
    #Foreach score in the keys of this score hash
    foreach my $score (sort {$b <=> $a} keys(%$score_hash))
      {
	#Foreach genome index in the array at this score
        foreach my $genome_index (@{$score_hash->{$score}})
	  {
	    #Push the genome index onto a temp array
	    push(@sorted_data,$snp_data_buffer->[$genome_index]);
	    push(@sorted_genome_names,$genome_names->[$genome_index]);
	  }
      }
    @$genome_names = @sorted_genome_names;
    @$snp_data_buffer = @sorted_data;

    verbose("\n");

    return(0);
  }


#This subroutine checks the names of genomes in the tree against those in the
#genome_names array created by LoadSNPs.  Note that this sub must be called
#before ConvertGenomesInTreeToIndexes
sub CheckTreeNames
  {
    #Read in the parameters
    my $tree         = $_[0];
    my $genome_names = $_[1];
    my $verbose      = $_[2];

    #Get the genome names stored in the leaves of the tree
    my $tree_names = $tree->getLeafKeys();

    #Create a hash to use to check the tree leaves
    my $tree_name_check = {};
    foreach my $name (@$tree_names)
      {$tree_name_check->{$name}++}

    #Initialize check status to successful
    my $status = 0;

    #Go through the genome names from the SNP file
    foreach my $name (@$genome_names)
      {
	verbose(1,"Checking genome: [$name].");

	#If there's not 1 occurrence of the name in the tree leaves
	if(!exists($tree_name_check->{$name}) ||
	   1 != $tree_name_check->{$name})
	  {
	    #Update status to failed
	    $status = 1;

	    #Print an error message
	    error("Genome name [$name] from the SNP data was found in tree [",
		  (exists($tree_name_check->{$name}) ?
		   $tree_name_check->{$name} : 0),
		  "] times.");
	  }
      }

    print STDERR ("\n") if($verbose);

    #Release the memory used by the finished tree name check hash
    undef($tree_name_check);

    #Create a hash to use to check the genome names
    my $genome_name_check = {};
    foreach my $name (@$genome_names)
      {$genome_name_check->{$name}++}

    #Go through the genome names from the tree file (in case
    #the tree has extra names that the SNP file didn't have)
    foreach my $name (@$tree_names)
      {
	verbose(1,"Checking leaf: [$name].");

	if(!exists($genome_name_check->{$name}) ||
	   1 != $genome_name_check->{$name})
	  {
	    #Update status to failed
	    $status = 1;

	    #Print an error message
	    error("Genome name [$name] from the tree data was found in the ",
		  "SNP data [",
		  (exists($genome_name_check->{$name}) ?
		   $genome_name_check->{$name} : 0),
		  "] times.");
	  }
      }

    #Return the success status
    return($status);
  }


#This subroutine simply assigns a numeric value to each genome and replaces the
#name in the tree with that value
sub ConvertGenomesInTreeToIndexes
  {
    #Read in parameters
    my $genome_names = $_[0];  #Array of genome names
    my $tree         = $_[1];  #Root node
    my $verbose      = $_[2];
    my $status = 0;  #Return value is success

    verbose("\tGathering tree leaves.");

    #Get all the leaves of the tree
    my $leaves = $tree->getLeafNodes();

    my $genome_indexes = {};
    foreach my $index (0..(scalar(@$genome_names) - 1))
      {$genome_indexes->{$genome_names->[$index]} = $index}

    #For each genome/leaf node
    foreach my $leaf_node (@$leaves)
      {
	 verbose(1,
		 "\tConverting leaf: [",
		 $leaf_node->getKey(),
		 ']');

	if(!exists($genome_indexes->{$leaf_node->getKey()}))
	  {
	    error("Missing genome in SNP data!: [",$leaf_node->getKey(),"].");
	    $status = 1;  #Return value is failure
	    last;
	  }

	$leaf_node->setKey($genome_indexes->{$leaf_node->getKey()});
      }

    return($status);
  }


#This subroutine takes a tree's root node and any other node and labels the
#numeric leaves with a 1 if they are below the node and 0 if not.  Note that
#this sub must be called after ConvertGenomesInTreeToIndexes
sub LabelGenomes
  {
    #Read in parameters
    my $num_genomes = $_[0];
    my $node        = $_[1];

    #Make a list of the leaves to be labelled
    my $label_genomes = $node->getLeafKeys();
    #Create the label array
    my $label_array   = [];

    my $last_genome = -1;
    #label the genomes with ones
    foreach my $genome (sort {$a <=> $b} @$label_genomes)
      {
	foreach my $unlabelled_genome (($last_genome + 1)..($genome - 1))
	  {$label_array->[$unlabelled_genome] = 0}
	$label_array->[$genome] = 1;
	$last_genome = $genome;
      }

    #Take care of the genomes between the last labelled one and the end
    foreach my $unlabelled_genome (($last_genome + 1)..($num_genomes - 1))
      {$label_array->[$unlabelled_genome] = 0}

    #Return the labelled array of genomes
    return($label_array);
  }



sub usage
  {
    print STDERR << "end";
USAGE: SNPSTI.pl -s snp_file -t tree_file [-v] [-h] [-m number] [-z number] [-n number] [-f] [-l] [-k] [-b] [-r] [-g] [-x number] [-u decimal from 0 to 1] [list of nodes to solve]
CLUSTER USAGE: See the "HOW TO PARALLELIZE SNPSTI" section of the --help output.

     -s   REQUIRED  Supply the name of the SNP input file
     -t   REQUIRED  Supply the name of the phylogenetic tree input file
     -v   OPTIONAL  [Off] Verbose mode
     -h   OPTIONAL  [Off] Help.  Use this option to see sample input files and
                    an explanation of how to interpret the output.
     -m   OPTIONAL  [3] Maximum number of SNPs per solution per phylogenetic
                    tree branch.  This must be greater than or equal to the -z
                    option.  If you supply a number here that is greater than
                    the number of SNPs in your SNP data file, it will be
                    silently changed to the number of available SNPs.
     -z   OPTIONAL  [1] Minimum number of SNPs per solution per phylogenetic
                    tree branch.  This must be less than or equal to the -m
                    option.  Note that if you use this option and solutions of
                    lesser size exist, those solutions will be repeated with
                    all combinations of every other SNP at the size you supply
                    for this parameter.
     -p   OPTIONAL  [3] This is the set size at which the -n and -j options
                    will begin to be used.  in other words, all solutions below
                    this set size will be computed regardless of the -n and -j
                    options.
     -n   OPTIONAL  [0] Minimum number of solutions to find per phylogenetic
                    tree node.  0 means \'Find all solutions within the maximum
                    number of SNPs restriction\'.  Iterations on a node will
                    cease once this number of solutions is found UNLESS this is
                    pre-empted by the minimum number of independent solutions
                    (see -j).  The -p option only activates this option after a
                    certain number of SNPs per solution is reached.
                    Note, use this if you want more solutions at a larger SNP
                    set size.  Otherwise, only all solutions at the smallest
                    set size are reported.  For example, if there\'s only one
                    solution at a set size of one and you want more solutions,
                    increasing this number to 2 will cause the program to look
                    for larger solutions sets.  Set this to 0 if you want all
                    solution sets up to the maximum number of SNPs.
     -j   OPTIONAL  [0] Minimum number of INDEPENDENT solutions to find per
                    phylogenetic tree node.  0 means 'Find all solutions within
                    the maximum number of SNPs restriction'.  Iterations on a
                    node will cease once this number of solutions is found
                    UNLESS this is pre-empted by the minimum number of
                    solutions (see -n).  The -p option only activates this
                    option after a certain number of SNPs per solution is
                    reached.
     -f   OPTIONAL  [Off] Turn on frame sort.  Use this when your SNPs are from
                    a gene and the SNP coordinates are relative to the reading
                    frame.  Solutions with a low cumulative frame total will
                    appear nearer to the top however note that solutions are
                    first sorted on number of evolutionary states.  Solutions
                    with the fewest states will appear at the top.
     -l   OPTIONAL  [Off] Low memory mode.  Slower.
     -k   OPTIONAL  [Off] Skip input check.  It is suggested you leave this off
                    unless you absolutely know the file is good by having run
                    it before and are running it again with different
                    parameters.  This option saves time.
     -b   OPTIONAL  [Off] Breadth first order.  Process the nodes in the
                    phylogenetic tree in breadth first order.  Default behavior
                    is depth-first order.
     -r   OPTIONAL  [Off] Reverse order.  Process the nodes in the phylogenetic
                    tree in reverse order.  Reversing is performed on a depth
                    first order unless the -b option is supplied.
     -i   OPTIONAL  [Off] Internal Nodes only.  This option tells the script to
                    only look for solutions to the internal nodes of the
                    phylogenetic tree (i.e. it ignores the leaves of the tree).
                    Cannot be used with the -e option.  This option overrides
                    the -b option.
     -e   OPTIONAL  [Off] Leaves only.  This option tells the script to only
                    look for solutions to the leaves of the phylogenetic tree
                    (i.e. it ignores the internal nodes of the tree).  Cannot
                    be used with the -i option.  This option overrides the -b
                    option.
     -a   OPTIONAL  [none] Starting node.  This option is useful if you stopped
                    SNPSTI.pl and want to resume where you left off.  Note, you
                    must use the same node ordering options to ensure all
                    undone nodes are done and none are redone.
          OPTIONAL  [none] List of node names to solve.  Note, there is no flag
                    for this option.  Simply supply the bare node names among
                    the other options.  If any node names have spaces in them,
                    use quotes to define them.
     -g   OPTIONAL  [Off] Use greedy heuristic to search for SNP solutions for
                    each branch of the phylogenetic tree.  This is faster than
                    the default exhaustive method, but is not guaranteed to
                    find all or any solutions.  However, greedy could be run
                    first and then do a second run using the command line to
                    list the nodes desired to be analyzed to solve the
                    remaining nodes exhaustively.
     -w   OPTIONAL  [original] (original,worst-case) The scoring function to
                    use in the greedy search of the data (see -g).  Scoring
                    functions determine how good a SNP combination is at
                    separating genomes under a subtree from the rest of the
                    tree.  The "original" scoring function uses a penalty based
                    on non-target genomes with no data for a particular SNP:
                    (SUM_over_all_states_s[(number_of_labelled_genomes_s^2 /
                    (number_of_genomes_s +
                    number_of_unlabelled_genomes_with_no_state)) /
                    number_of_labelled_genomes]).  The worst-case scenario
                    scoring function is similar, except it selects the worst
                    possible value that SNPs with no data for a genome could be
                    when there's no data for it.
     -o   OPTIONAL  [Off] Skip the exhaustive search.  This option only works
                    if -g is supplied.  Note, you should use this option along
                    with --partial-suffix in order to save your greedy reult
                    output.
     -x   OPTIONAL  [20] Maximum number of greedily selected SNPs to
                    exhaustively search.  Note, the default value is only used
                    if -g is supplied.  If this value is explicitly set on the
                    command line, then -g is "turned on".  If this value is set
                    to 0, then -u must not be 0.  If -u is set, the final set
                    of SNPs may be lesser in size than max_greedies if there
                    are not enough SNPs above the quality cutoff for any one
                    solution.  Note that if a SNP added to the greedy set is a
                    perfect solution, it is added to the greedy set, but not
                    counted, so your number of greedy SNPs in the final set
                    could be more than the number specified through this
                    option.
     -u   OPTIONAL  [0.1] Quality ratio cut-off.  If a SNP being added to the
                    greedy set further resolves fewer than this fraction of
                    genomes and max_greedies has not yet
                    been reached (or is zero), the current greedy solution will
                    be saved and a new greedy solution will be started.
     -c   OPTIONAL  [0] When two SNPs both improve a solution by the same
                    amount, the fraction between 0 and 1 set here will
                    determine the chance that the next same-quality SNP will be
                    chosen over the first one encountered.  A value of zero
                    means that the first best SNP encountered will be added to
                    the greedy solution.  A value of one means that the last
                    best SNP encountered will always be added to the solution.


     --partial-suffix  OPTIONAL [.prtl] Suffix to be appended to input file for
                                storing partial greedy solutions.
     --overwrite       OPTIONAL [Off] Overwrite existing partial greedy
                                solutions files.
     --debug           OPTIONAL [Off] Get debug output on STDERR to help
                                diagnose problems.  May be set to a positive
                                integer or supplied multiple times to increase
                                the amount of debug output.
end
  }



sub help
  {
    #Print a description of this program
    print STDERR ("SNP Sub-Tree Isolator (SNPSTI.pl)\n",
		  "Robert W. Leach\n",
		  "Center for Computational Research\n",
		  "Buffalo, NY 14203\n",
		  "rwleach\@ccr.buffalo.edu\n\n");
    print STDERR ("* WHAT IS THIS: This program takes a phylogenetic tree ",
		  "and SNP data and assigns SNP values to the branches of ",
		  "the phylogenetic tree.  These values uniquely identify ",
		  "the genomes in the sub-trees.  Multiple solutions are ",
		  "output per branch, but only the smallest possible set of ",
		  "SNPs is used in the solutions reported.\n\n");
    print STDERR ("* RESULTS INTERPRETATION: Results are ordered by nodes in ",
		  "the phylogenetic tree in a depth-first-search manner.  ",
		  "Each branch (represented by the node it leads to) has a ",
		  "set of results.  For any particular result, you get a set ",
		  "of SNP IDs and an array of 0s, 1s, and _s.  Each array ",
		  "element is the leaf of a 6 degree tree where each node ",
		  "has six branches (from left to right: .ATGC-).  Each level ",
		  "of the quarternary tree (from top down) represents a SNP ",
		  "from the set of SNP IDs from left to right.  The tree can ",
		  "be constructed from these two sets of data.  By following ",
		  "the SNP values down the tree, the resulting chacter (_, ",
		  "0, or 1) tells you whether the SNP values identify a ",
		  "genome in the current sub-tree of the phylogenetic ",
		  "tree.  A 1 means it belongs to the sub-tree and a 0 means ",
		  "it doesn\'t belong to the sub-tree.  An _ ",
		  "means that the combination of SNP values does not occur ",
		  "in any genome in the phylogenetic tree.\n\n");
    print STDERR ("* SNP FILE FORMAT: Basically, this is a white-space ",
		  "delimited file where the first row is the column names ",
		  "which is made up of SNP positions in the sequences, ",
		  "the first column is genome names, and each 'cell' ",
		  "is a sequence character.  Here is a table of sequence ",
		  "characters and what they mean.  Case is not important.\n\n",
		  "     A     Adenosine\n",
		  "     T     Thymidine\n",
		  "     G     Guanosine\n",
		  "     C     Cytidine\n",
		  "     -     Gap in an alignment (due to either deletion or ",
		  "insertion)\n",
		  "     N,X,? A, T, G, or C\n",
		  "     X     A, T, G, or C\n",
		  "     B     C, G, or T\n",
		  "     D     A, G, or T\n",
		  "     H     A, C, or T\n",
		  "     V     A, C, or G\n",
		  "     S     G or C\n",
		  "     W     A or T\n",
		  "     R     A or G\n",
		  "     Y     C or T\n",
		  "     K     G or T\n",
		  "     M     A or C\n",
		  "     .     A, T, G, C, or -.  Non-existant SNP (i.e. when ",
		  "the gene in which the\n",
		  "           SNP resides is absent.  Only useful for ",
		  "multilocus analyses involving\n",
		  "           multiple genes.)  It tells SNPSTI to ignore ",
		  "this SNP because it adds\n",
		  "           no information to the analysis.\n\n",
		  "Alternatively, generic evolutionary states can be ",
		  "represented with numbers (0-4).  These numbers are ",
		  "effectively the same as these states:\n\n",
		  "     1     A\n",
		  "     2     T\n",
		  "     3     G\n",
		  "     4     C\n",
		  "     5     -\n\n",
		  "0-4 cannot be mixed with ATGC- in one column of SNP ",
		  "data.  An example of how to use a generic evolutionary ",
		  "state/event is the loss of a gene.  If a particular gene ",
		  "has been lost in one genome, you would put dots (.) in ",
		  "the SNP columns for that gene (so that they will be ",
		  "ignored) and add a a column that represents the loss of ",
		  "the gene.  If the genome on a row is missing the gene, ",
		  "you\'d arbitrarily put a 0.  Otherwise, you'd put a 1.\n\n",
		  "The number of white spaces between columns doesn't ",
		  "matter, except that the row names and the first column of ",
		  "SNP data must be separated by a tab.  You may put ",
		  "comments on lines in the file not containing data as long ",
		  "as the line's first character is a # character.\n\nHere ",
		  "is an example file (Note the first indent seen here is ",
		  "not a part of the file and the first and second columns ",
		  "are separated by a tab.  The rest are a variable number ",
		  "of spaces.):\n\n",
		  "     #My SNP data example\n",
		  "     \n",
		  "                5 12 23 25 69 72 75 88 91\n",
		  "     \n",
		  "     genome1    C  T  G  A  T  G  C  G  C\n",
		  "     genome2    C  T  A  G  C  G  G  C  T\n",
		  "     genome3    A  C  G  C  T  G  T  C  G\n",
		  "     genome4    T  G  C  G  C  G  A  C  C\n",
		  "\nFor multi-locus analyses, the SNP positions may have ",
		  "non-numeric gene names preceding the position like this:\n",
		  "\n",
		  "     #My multilocus SNP data example\n",
		  "     \n",
		  "                gyr5 gyr22 gyr29 rpo10 rpo11 rpo36 rpo64\n",
		  "     \n",
		  "     genome1       C     T     G     A     T     G     C\n",
		  "     genome2       C     T     A     G     C     G     G\n",
		  "     genome3       A     C     G     C     T     G     T\n",
		  "     genome4       T     G     C     G     C     G     A\n",
		  "\n",
		  "Column headings for extra generic evolutionary ",
		  "information may not have numbers in them.  Let's use the ",
		  "same example as above, but let's say that genomes 1 and 2 ",
		  "are missing the gyrase gene (represented by SNPs in the ",
		  "first three columns).  The table would then look like ",
		  "this:\n\n",
		  "     #My multilocus missing gene SNP data example\n",
		  "     \n",
		  "                gyr5 gyr22 gyr29  delA rpo10 rpo11 rpo36\n",
		  "     \n",
		  "     genome1       .     .     .     0     A     T     G\n",
		  "     genome2       .     .     .     0     G     C     G\n",
		  "     genome3       A     C     G     1     C     T     G\n",
		  "     genome4       T     G     C     1     G     C     G\n",
		  "\nHere you see that there is no SNP data for the missing ",
		  "genes in those genomes and the deletion of the gene is ",
		  "represented in the fourth column as a single evolutionary ",
		  "event.  I arbitrarily named the deletion event 'delA'.\n\n"
		 );
    print STDERR ("* PHYLOGENETIC TREE FILE FORMAT: The tree file takes the ",
		  "form of an outline.  Note that spaces are significant.  ",
		  "They indicate the 'indent', i.e. where a node occurs in ",
		  "the tree.  Genomes are at the leaves and MUST have the ",
		  "same names used in the SNP input file.  Internal nodes ",
		  "may have any name you want.  You could use numbers or ",
		  "letters, but make sure they are unique, because they will ",
		  "appear in the output to assign SNP values to the ",
		  "branches.  The tree must also be binary, meaning that ",
		  "each node has only two child nodes.  There may also be ",
		  "comments in this file on lines starting with # characters.",
		  "\n\nHere is an example file (note the indent seen here is ",
		  "not a part of the file):\n\n",
		  "     #My Tree Test Data\n",
		  "     \n",
		  "     node0\n",
		  "      node1\n",
		  "       node2\n",
		  "        genome1\n",
		  "        genome2\n",
		  "       node3\n",
		  "        genome3\n",
		  "        genome4\n\n");
    print STDERR << "end";
* USING THE GREEDY OPTIONS: The three greedy options are -g|--greedy,
                            -x|--max-greedies, -u|--quality-ratio, and
                            -c|--chance.  By explicitly setting -x or -u, -g is
                            "turned on" automatically.  max-greedies is the
                            maximum number of SNPs to be greedily collected and
                            exhaustively searched for perfect solutions.  A
                            greedy solution is built up based on the best
                            improvement you get from adding an extra SNP to the
                            greedy solution.  In other words, you keep adding
                            SNPs based on how well the SNP being added resolves
                            the origanisms remaining to be resolved.  So if I
                            had a greedy solution that resolved all but 5
                            organisms, I will add the next of the remaining
                            SNPs which resolves the most of those 5.  If you
                            supply a quality-ratio of say .5, and the best SNP
                            that resolves the most of the remaining 5 resolves
                            only 2 more organisms, the last best SNP will be
                            added, but after which a new greedy solution will
                            be started.  When the total SNPs greedily collected
                            either reaches the max-greedies limit or no more
                            SNPs are above the quality ratio, the greedy search
                            will end and the exhaustive search of the greedily
                            collected SNPs will begin.  A greedy search will be
                            performed for each node of the phylogenetic tree
                            being analyzed (based on other parameters).  Note
                            that if a SNP added to the greedy set causes the
                            greedy set to be a perfect solution, the SNP is
                            added, but not counted, so the final number of
                            greedy SNPs can be larger than what is specified by
                            max-greedies.  The smaller the value for max-
                            greedies is, the faster the program will run, but
                            the more chance there is of missing a perfect
                            solution.  However, if you want more solutions for
                            any particular nodes, you can rerun the program on
                            just those nodes by supplying node names on the
                            command line (the option without a flag in the
                            USAGE output).  The quality-ratio is used not for
                            speed, but to manage the number of greedy
                            iterations for any one node.  If the quality ratio
                            was set to zero and no perfect solutions are
                            encountered in the greedy built solution, you would
                            likely end up adding junk SNPs that contain no real
                            information and are improving the solution by pure
                            chance.  You would completely miss other possibly
                            very good or even perfect solutions that happen to
                            not have any one SNP that well resolves the node.
                            For example, a ratio of a half will ensure that
                            each SNP added to the greedy solution will resolve
                            half of the genomes that have not yet been
                            resolved.  However, due to small SNP anomolies, it
                            is recommended to keep this ratio fairly low.  See
                            the usage output to get an explanation of the
                            chance option.

* HOW TO PARALLELIZE SNPSTI: SNPSTI.pl is very parallelizable.  You can run
                             each tree node separately in a different process.
                             All you have to do is execute the same command
                             many times, but provide a different tree node on
                             the command line each time.  There are two
                             environment variables that can be utilized to pass
                             arguments and include paths to cluster nodes:

                               SNPSTI_CLUSTER_PARAMS
                               SNPSTI_CLUSTER_TREE_PATH

                             Simply set SNPSTI_CLUSTER_PARAMS to be one long
                             string containing all the arguments to SNPSTI.pl.
                             The presence of this environment variable (and the
                             absence of any command line arguments) tells
                             SNPSTI to grab the arguments from the environment
                             variable.  Similarly, the presence of the
                             SNPSTI_CLUSTER_TREE_PATH environment variable (and
                             the absence of any command line arguments) tells
                             SNPSTI to add the tree.pm module in the location
                             given in the environment variable.  Note that if
                             tree.pm exists anywhere else in the @INC array, it
                             will occlude the instance your environment
                             variable adds.  You can run instances of this
                             script in parallel, each solving a different node
                             of the tree.  Example:

                               /path/to/SNPSTI.pl test_node1 -s input.snps -t input.tree -v > test_node1_output.txt
                               /path/to/SNPSTI.pl test_node2 -s input.snps -t input.tree -v > test_node2_output.txt
                               /path/to/SNPSTI.pl test_node3 -s input.snps -t input.tree -v > test_node3_output.txt
                               /path/to/SNPSTI.pl test_node4 -s input.snps -t input.tree -v > test_node4_output.txt
                               ...

                             NOTE: If you have very large input files, you
                             should run multiple tree nodes per process because
                             the initialization step has a large constant time
                             overhead that each instance must perform.  The
                             same input files for each process is a requirement
                             because the search space for each process is the
                             same.  It\'s only the search context (i.e.
                             phylogenetic tree node) which changes.

end
  }



#This sub takes a solution hash which contains various output strings and
#scores and prints them sorted on that score.
sub printSortedResults
  {
    #Read in the parameters
    my $solutions = $_[0];
    my $framesort = $_[1];
    my $scores = {};

    #Print the message
    print($solutions->{message});

    #For each solution in the output array
    foreach my $sol (@{$solutions->{output}})
      {
	##Sum the frame positions.  The lower the sum, the better the SNP is as
	##an identifier because there's higher genetic pressure to not change.
	##If it does change, it's less likely to change again and saturate the
	##data.

	#Grab the portion of the string that
	#contains the space-delimited SNP positions
	my $snp_area;
	($snp_area) = ($sol =~ /\t([^\t]+)\t/g);

	my $framesum = 0;

	##If I disallow numbers as headers of columns containing generic
	##evolutionary events, I won't need to do anything here.  Otherwise, I
	##must make sure I don't use their numbers in the frame calculation
	##here.

	if($framesort)
	  {map {$framesum += 3 - ($1 % 3)} ($snp_area =~ /(\d+)/g)}

	##Determine the number of total character states a SNP has in the data.
	##The lower the number of states a SNP has, the better an identifier it
	##is because it's less evolutionarily saturated.

	#Reset the match position
	pos($sol) = 0;
	my $label_area;
	#Grab the portion of the string that
	#contains the space-delimited labels
	($label_area) = ($sol =~ /\t([^\t]+)$/g);
	#Count the the number of existing states in the
	#tree leaves (i.e. anything with a numeric label)
	(@states) = ($label_area =~ /(\d+)/g);

	#Record the scores for this solution
	$scores->{$sol}->{states} = scalar(@states);
	$scores->{$sol}->{frames} = $framesum;
      }

    #Print sorted by number of states.  If the number of states is the same,
    #sort based on framesum
    print(sort {($scores->{$a}->{states} == $scores->{$b}->{states} ?
		 ($scores->{$a}->{frames} <=> $scores->{$b}->{frames}) :
		 ($scores->{$a}->{states} <=> $scores->{$b}->{states}))}
	  @{$solutions->{output}});
  }


sub getSNP
  {
    my $buffer       = $_[0];
    my $genome_index = $_[1];
    my $snp_index    = $_[2];
    my $snp_val = '';
    #Get the global value
    my $low_mode = $low_memory_mode;

    error("Invalid genome index: [$genome_index].")
      if($genome_index !~ /^-?\d+$/);
    if(abs($genome_index) > $#{$buffer})
      {
	error("Genome index: [$genome_index] overextends the array bounds: [",
	      scalar(@$buffer),
	      "]!");
	return('');
      }

    error("Invalid SNP index: [$snp_index].")
      if($snp_index !~ /^-?\d+$/);
    if(abs($snp_index) > ($low_mode ?
			  (length(${$buffer->[$genome_index]}) - 1) :
                          scalar(@{$buffer->[$genome_index]})))
      {
	error("SNP index: [$snp_index](SNP $snp_names->[$snp_index]) ",
	      "overextends the array bounds: [",
	      ($low_mode ?
	       "LOW MEMORY SIZE:" . (length(${$buffer->[$genome_index]}) - 1) :
	       scalar(@{$buffer->[$genome_index]})),
	      "] for genome index: [$genome_index]",
	      "(genome $genome_names->[$genome_index])!");#  Number of SNPs should be: [",scalar(@$snp_names),"].\n${$buffer->[$genome_index]}\n");
exit;
        return('');
      }

    if($low_mode)
      {$snp_val = substr(${$buffer->[$genome_index]},$snp_index,1)}
    else
      {$snp_val = $buffer->[$genome_index]->[$snp_index]}

    if($snp_val !~ /\S/)
      {
	my($junk,$junk,$junk,$calling_sub) = caller(1);
	die("ERROR:$calling_sub:getSNP:No SNP value at specified location ",
	    "(genome index: [$genome_index], SNP index: [$snp_index])!\n");
      }

    return($snp_val);
  }



#This is not estimating even close to the amount of time.  Fix it before reincorporating the calls I took out
sub timeRemainingEstimate
  {
    use Math::BigInt;
    my $combos_so_far      = $_[0];
    my $num_snps           = $_[1];
    my $min_combo_size     = $_[2];
    my $max_combo_size     = $_[3];
    my $num_tree_nodes     = $_[4];
    my($time_so_far);

    if(!defined($main::total_combos))
      {
	$time_so_far = markTime();
	$main::total_combos = 0;
	foreach my $r ($min_combo_size..$max_combo_size)
	  {$main::total_combos += numCombos($num_snps,$r)}
	$main::total_combos *= $num_tree_nodes;
	return('?');
      }

    $time_so_far = markTime(0);

    #Return the estimated time remaining
    return(($time_so_far / $combos_so_far) *
	   ($main::total_combos - $combos_so_far));
  }



#This sub calculates "n choose r"
sub numCombos
  {
    my $n = $_[0];
    my $r = $_[1];
    my $a = $n;
    foreach(1..$r)
      {$a *= --$n}
    $a /= factorial($r);
    return($a);
  }



sub factorial
  {
    my $n = $_[0];
    return(1) if($n == 1);
    return(0) if($n == 0);
    return($n * factorial($n - 1));
  }



#This sub marks the time (which it pushes onto an array) and in scalar context
#returns the time since the last mark by default or supplied mark (optional)
#In array context, the time between all marks is always returned regardless of
#a supplied mark index
#A mark is not made if a mark index is supplied
#Uses a global time_marks array reference
sub markTime
  {
    #Record the time
    my $time = time();

    #Set a global array variable if not already set
    $main::time_marks = [] if(!defined($main::time_marks));

    #Read in the time mark index or set the default value
    my $mark_index = (defined($_[0]) ? $_[0] : -1);  #Optional Default: -1

    #Error check the time mark index sent in
    if($mark_index > (scalar(@$main::time_marks) - 1))
      {
	error("Supplied time mark index is larger than the size of the ",
	      "time_marks array.\nThe last mark will be set.");
	$mark_index = -1;
      }

    #Calculate the time since the time recorded at the time mark index
    my $time_since_mark = (scalar(@$main::time_marks) ?
			   ($time - $main::time_marks->[$mark_index]) : 0);

    #Add the current time to the time marks array
    push(@$main::time_marks,$time)
      if(!defined($_[0]) || scalar(@$main::time_marks) == 0);

    #If called in array context, return time between all marks
    if(wantarray)
      {
	if(scalar(@$main::time_marks) > 1)
	  {return(map {$main::time_marks->[$_ - 1] - $main::time_marks->[$_]}
		  (1..(scalar(@$main::time_marks) - 1)))}
	else
	  {return(())}
      }

    #Return the time since the time recorded at the supplied time mark index
    return($time_since_mark);
  }



##
## Subroutine that prints errors with a leading program identifier
##
sub error
  {
    return(0) if($quiet);

    #Gather and concatenate the error message and split on hard returns
    my @error_message = split("\n",join('',@_));
    pop(@error_message) if($error_message[-1] !~ /\S/);

    $main::error_number++;

    my $script = $0;
    $script =~ s/^.*\/([^\/]+)$/$1/;

    #Assign the values from the calling subroutines/main
    my @caller_info = caller(0);
    my $line_num = $caller_info[2];
    my $caller_string = '';
    my $stack_level = 1;
    while(@caller_info = caller($stack_level))
      {
	my $calling_sub = $caller_info[3];
	$calling_sub =~ s/^.*?::(.+)$/$1/ if(defined($calling_sub));
	$calling_sub = (defined($calling_sub) ? $calling_sub : 'MAIN');
	$caller_string .= "$calling_sub(LINE$line_num):"
	  if(defined($line_num));
	$line_num = $caller_info[2];
	$stack_level++;
      }
    $caller_string .= "MAIN(LINE$line_num):";

    my $leader_string = "ERROR$main::error_number:$script:$caller_string ";

    #Figure out the length of the first line of the error
    my $error_length = length(($error_message[0] =~ /\S/ ?
			       $leader_string : '') .
			      $error_message[0]);

    #Put location information at the beginning of each line of the message
    foreach my $line (@error_message)
      {print STDERR (($line =~ /\S/ ? $leader_string : ''),
		     $line,
		     ($verbose &&
		      defined($main::last_verbose_state) &&
		      $main::last_verbose_state ?
		      ' ' x ($main::last_verbose_size - $error_length) : ''),
		     "\n")}

    #Reset the verbose states if verbose is true
    if($verbose)
      {
	$main::last_verbose_size = 0;
	$main::last_verbose_state = 0;
      }

    #Return success
    return(0);
  }



##
## Subroutine that checks to see if solutions found so far occur inside another
##
sub smallSolutionInside
  {
    my $current_set = $_[0];
    my $small_sets  = $_[1];
    my $presense = 0;

    #For each small solution
    foreach my $small_solution_set (@$small_sets)
      {
	my $matches = 0;
	my $no_match = 0;
	my $current_position = 0;

	#For each SNP in the small solution
	for(my $snp_position = 0;
	    $snp_position < scalar(@$small_solution_set);
	    $snp_position++)
	  {
	    #For each position in the current set
	    for(my $position = $current_position;
		$position < scalar(@$current_set);
		$position++)
	      {
		#If the SNPs in the small and current solutions match
		if($current_set->[$position] ==
		   $small_solution_set->[$snp_position])
		  {
		    #Increment the number of matches to the small solution
		    $matches++;
		    #Set the position to start at in the current set for
		    #checking the next SNP from the small solution (we can do
		    #this because the SNPs are in order)
		    $current_position = $position + 1;

		    last;
		  }
		#Else if the small solutions SNP wasn't found (in order) in the
		#current set OR the remainder of the current set is larger than
		#the remainder of the small set
		elsif($current_set->[$position] >
		      $small_solution_set->[$snp_position] ||
		      (scalar(@$current_set) - 1 - $position) <
		      (scalar(@$small_solution_set) - 1 - $snp_position))
		  {
		    #These solutions cannot match
		    $no_match = 1;
		    last;
		  }
	      }

	    #If this small set cannot match, go to the next one
	    last if($no_match);
	  }

	#If there's a match for all the SNPs in the small solution
	if($matches == scalar(@$small_solution_set))
	  {
	    $presense = 1;
	    last;
	  }
      }

    #return the true/false presence of a small solution in the current set
    return($presense);
  }


##
## Subroutine that prints warnings with a leader string
##
sub warning
  {
    return(0) if($quiet);

    #Gather and concatenate the warning message and split on hard returns
    my @warning_message = split("\n",join('',@_));
    pop(@warning_message) if($warning_message[-1] !~ /\S/);

    #Put leader string at the beginning of each line of the message
    foreach my $line (@warning_message)
      {print STDERR (($line =~ /\S/ ? 'WARNING: ' : ''),$line,"\n")}

    #Return success
    return(0);
  }



sub getNextGreedySNP
  {
    my $greedy_snp_candidates = $_[0];
    my $greedy_snp_pool       = $_[1];
    my $snp_data_buffer       = $_[2];
    my $label_array           = $_[3];
    my $equal_chance          = (defined($_[4]) ? $_[4] : 0);
    my $snp_names             = $_[5];
    my $verbose               = $_[6];
    my $greedy_sol_num        = $_[7];
    my $relevant_genomes      = $_[8];
    my $scoring_function      = $_[9];

    #print STDERR "TEST GREEDY SNP POOL: [@$greedy_snp_pool]\n";

    my($score,$maxscore,$maxsnp,$line);
    my $linesize = 0;
    my $greedy_pool_index = 0;
    my $max_index = 0;
    my $greedymsg = '';
    my $prtl_soln_tree = tree->new('GREEDY ITER ' . $greedy_sol_num . ' SIZE '
				   . (scalar(@$greedy_snp_candidates) + 1));
    foreach my $snp (@$greedy_snp_pool)
      {
	#print STDERR "TEST GREEDILY EVALUATING SNP: $snp WITH CANDIDATES: @$greedy_snp_candidates\n";

	$score = getRatioResolved((scalar(@$greedy_snp_candidates) ?
				   [map {$optimized_snps->[$_]->[0]}
				    (@$greedy_snp_candidates,$snp)] :
				   [$optimized_snps->[$snp]->[0]]),
				  $snp_data_buffer,
				  $label_array,
				  $relevant_genomes,
				  $scoring_function,
				  #1
				 );

	#print STDERR "TEST: SCORE FOR SNP $snp_names->[$snp]: $score\n";

	if(!defined($maxscore) || $score > $maxscore ||
	   ($equal_chance && $score == $maxscore && rand() < $equal_chance))
	  {
	    $max_index = $greedy_pool_index;

	    $maxscore = $score;
	    $maxsnp   = $snp;

            $greedymsg = "GREEDY ITERATION: [$greedy_sol_num]  SIZE: [" .
              (scalar(@$greedy_snp_candidates) + 1) .
                "] SNP [$snp_names->[$optimized_snps->[$snp]->[0]]] SCORE = $score.  " .
                  "MAX [$snp_names->[$optimized_snps->[$maxsnp]->[0]]] = $maxscore.\n"
	  }

	verbose(1,
		"GREEDY ITERATION: [$greedy_sol_num]  SIZE: [",
		scalar(@$greedy_snp_candidates) + 1,
		"] ",
		"SNP [$snp_names->[$optimized_snps->[$snp]->[0]]] ",
		"SCORE = $score.  ",
		"MAX [$snp_names->[$optimized_snps->[$maxsnp]->[0]]] = ",
		"$maxscore.");

	$greedy_pool_index++;

	#I'm doing a pattern match here just in case the real number wouldn't
	#work using == against an integer
	if($score == 1)
	  {last}
      }

    #This call is purely just to get the $prtl_soln_tree filled in
    getRatioResolved((scalar(@$greedy_snp_candidates) ?
		      [map {$optimized_snps->[$_]->[0]}
		       (@$greedy_snp_candidates,$maxsnp)] :
		      [$optimized_snps->[$maxsnp]->[0]]),
		     $snp_data_buffer,
		     $label_array,
		     $relevant_genomes,
		     $scoring_function,
		     #1,
		     $prtl_soln_tree);

    if($partial_suffix ne '')
      {
        print PRTL $greedymsg;
	my $handle = select(PRTL);
	$prtl_soln_tree->printTree();
	select($handle);
      }

    splice(@$greedy_snp_pool,$max_index,1);

    push(@$greedy_snp_candidates,$maxsnp);
    return($maxscore);
  }



#This sub scores proposed solutions based on the ratio of labelled versus
#unlabelled genomes in each well.  It returns a "resolved" score between 0 and
#1 (inclusive) for the labelled genomes indicating roughly the ratio of target
#leaves that are separated from non target leaves.  If ambiguous nucleotides
#exist in the data, these numbers may grow because genomes will be thrown into
#multiple branches of the solution tree corresponding to the nucleotides the
#ambiguous nucleotide stands for.
sub getRatioResolved
  {
    use strict;

    my($snp,$proposed_solution);
    #Break off the first snp in the array and store the rest in the
    #proposed_solution which will be sent in a recursive call
    ($snp,@$proposed_solution) = @{$_[0]};

    my $snp_data_buffer        = $_[1];  #Array of SNP strings for each genome
    my $label_array            = $_[2];  #Array of genome labels indexed by
                                         #genome
    my $relevant_genomes       = $_[3];  #Array of genome indexes to consider
    my $scoring_function       = (defined($_[4]) ? $_[4] : 'original');
    my $prtl_soln_tree         = $_[5];  #A tree.pm object to be filled with
                                         #a partial solution. Initially empty.
    my $counted_scores         = $_[6];  #INTERNAL USE ONLY.  DO NOT SUPPLY.
                                         #Genomes whose scores "count" will be
                                         #labelled in this array.  A genome
                                         #"counts" if it's been placed in a
                                         #real well because a SNP value put it
                                         #there (other than a dot). This allows
                                         #us to skip genomes which provide no
                                         #information for the particular set of
                                         #SNPs supplied UNTIL a real value is
                                         #encountered. It is assumed/guaranteed
                                         #elsewhere that all genomes will have
                                         #a value for at least one of the SNPs
                                         #provided (if not, 0 is returned).
                                         #INTERNAL USE ONLY.  DO NOT SUPPLY.
    my $num_possible_states    = $_[7];  #INTERNAL USE ONLY.  DO NOT SUPPLY.
    my $first_call    = (defined($_[8]) ? 0 : 1);  #INTERNAL USE ONLY.
                                                   #DO NOT SUPPLY.

    print STDERR ("DEBUG: Call to getRatioResolved.\n") if($first_call && $DEBUG);

    my $do_soln_tree = (defined($prtl_soln_tree) &&
			ref($prtl_soln_tree) eq 'tree' ? 1 : 0);
    my $going_to_recurse = scalar(@$proposed_solution);

    #If this is a recursive call and the well was empty, return 0
    if(!$first_call && scalar(@$label_array) == 0)
      {
	#If we're building a partial solution tree
	if($do_soln_tree)
	  {
	    #We'll add the unlabeled genomes directly under this branch because
	    #the values for the current SNP do not matter since it's already
	    #completely resolved from here
	    foreach my $genom (map {'- ' . $genome_names->[$_]}
			       @$relevant_genomes)
	      {$prtl_soln_tree->addChild(tree->new($genom))}
	  }

	return(0);
      }

    #Initialize counted_scores to 0 if not set (should happen on 1st call only)
    if(!defined($counted_scores))
      {$counted_scores = [map {0} @$label_array]}

    #Initialize num_possible_states to 1 if not set (should happen on 1st call
    #only)
    if(!defined($num_possible_states))
      {$num_possible_states = [map {1} @$label_array]}

    #Initialize variables local to this recursive call
    my $real_label_counts       = [0,0,0,0,0,0];       #Number of genomes in
                                                       #each well that didn't
                                                       #originate from a
                                                       #pseudo-well
    my $label_counts            = [0,0,0,0,0,0];       #Number of labelled
                                                       #organisms in each well
    my $total_counts            = [0,0,0,0,0,0];       #Number of total
                                                       #organisms in each well
    my $new_label_array         = [[],[],[],[],[],[]]; #Labels are split the 
                                                       #same way as genomes in
                                                       #the genome wells for
                                                       #the next recursive call
    my $new_relevant_genomes    = [[],[],[],[],[],[]]; #Same as above
    my $new_counted_scores      = [[],[],[],[],[],[]];
    my $new_num_possible_states = [[],[],[],[],[],[]]; #Number of possible
                                                       #values a specific SNP
                                                       #combination can have
                                                       #for a single genome.
                                                       #This is intended to
                                                       #estimate the
                                                       #possibilities for SNPs
                                                       #whose values are
                                                       #ambiguous (e.g. . = 5,
                                                       #N = 4, S = 2, etc.)
    my $weighted_label_counts   = [0,0,0,0,0,0];       #Number of labelled
                                                       #organisms in each well
                                                       #weighted by the number
                                                       #of states
    my $weighted_total_counts   = [0,0,0,0,0,0];       #Number of total
                                                       #organisms in each well
                                                       #weighted by the number
                                                       #of states

    #Note, the calculations for the number of possible states are based on
    #possible SNP values.  If other information is encoded in the data, it will
    #be assumed that there are 5 possible values when a dot is encountered,
    #thus a dot should not be used for missing data.

    ##
    ## The first steps in the process are to determine:
    ##   1. the value of the SNP,
    ##   2. which well(s) the genome and associated data goes into, and
    ##   3. whether the genome should be treated as real data or "no data"
    ##

    my($matched);
    my $relevant_genome_index = -1;

    #For each genome
    foreach my $real_genome_index (@$relevant_genomes)
      {
	$relevant_genome_index++;

	#Get the current SNP's value for this genome
	my $snp_val = getSNP($snp_data_buffer,$real_genome_index,$snp);

	$num_possible_states->[$relevant_genome_index] *=
	  getNumStates($snp_val);

	$matched = 0;

	#I want to get a partial score on SNPs when some of the genomes have a
	#set of totally ambiguous SNPs, so I need to comment out the code
	#below.  Every node is going to have some totally ambiguous genomes for
	#the set of SNPs, but I want to get a score regardless so I can pick
	#those SNPs that still cover a bunch of genomes so that other SNPs
	#later can be added that those genomes have SNP values for

	if($snp_val eq '.')
	  {
	    $matched = 1;

	    #If this genome is labelled
	    if($label_array->[$relevant_genome_index])
	      {
		$label_counts->[0]++;

		$weighted_label_counts->[0] +=
		  1 / $num_possible_states->[$relevant_genome_index];

		#If this genome was placed here by a real valued SNP (not a .)
		if($counted_scores->[$relevant_genome_index])
		  {$real_label_counts->[0]++}
	      }

	    $total_counts->[0]++;

	    $weighted_total_counts->[0] +=
	      1 / $num_possible_states->[$relevant_genome_index];

	    #Push the current genome's SNP data and labels into the dot well
	    push(@{$new_label_array->[0]},
		 $label_array->[$relevant_genome_index]);
	    push(@{$new_relevant_genomes->[0]},
		 $relevant_genomes->[$relevant_genome_index]);
	    push(@{$new_counted_scores->[0]},
		 $counted_scores->[$relevant_genome_index]);
	    push(@{$new_num_possible_states->[0]},
		 $num_possible_states->[$relevant_genome_index]);
	  }
	else
	  {
	    $counted_scores->[$relevant_genome_index] = 1 if($first_call);

	    #If the first snp value from the proposed solution contains an A or
	    #1 for this genome
	    if($snp_val =~ /^[a1dhvrmwnx]$/i)
	      {
		$matched = 1;

		if($label_array->[$relevant_genome_index])
		  {
		    $label_counts->[1]++;

		    $weighted_label_counts->[1] +=
		      1 / $num_possible_states->[$relevant_genome_index];

		    #If this genome was placed here by a real SNP value (not .)
		    if($counted_scores->[$relevant_genome_index])
		      {$real_label_counts->[1]++}
		  }

		$total_counts->[1]++;

		$weighted_total_counts->[1] +=
		  1 / $num_possible_states->[$relevant_genome_index];

		#Push the current genome's SNP data and labels into the A well
		push(@{$new_label_array->[1]},
		     $label_array->[$relevant_genome_index]);
		push(@{$new_relevant_genomes->[1]},
		     $relevant_genomes->[$relevant_genome_index]);
		push(@{$new_counted_scores->[1]},1);
		push(@{$new_num_possible_states->[1]},
		     $num_possible_states->[$relevant_genome_index]);
	      }

	    #If the first snp value from the proposed solution contains a T or
	    #2 for this genome
	    if($snp_val =~ /^[t2bdhykwnx]$/i)
	      {
		$matched = 1;

		if($label_array->[$relevant_genome_index])
		  {
		    $label_counts->[2]++;

		    $weighted_label_counts->[2] +=
		      1 / $num_possible_states->[$relevant_genome_index];

		    #If this genome was placed here by a real SNP value (not .)
		    if($counted_scores->[$relevant_genome_index])
		      {$real_label_counts->[2]++}
		  }

		$total_counts->[2]++;

		$weighted_total_counts->[2] +=
		  1 / $num_possible_states->[$relevant_genome_index];

		#Push the current genome's SNP data and labels into the T well
		push(@{$new_label_array->[2]},
		     $label_array->[$relevant_genome_index]);
		push(@{$new_relevant_genomes->[2]},
		     $relevant_genomes->[$relevant_genome_index]);
		push(@{$new_counted_scores->[2]},1);
		push(@{$new_num_possible_states->[2]},
		     $num_possible_states->[$relevant_genome_index]);
	      }

	    #If the first snp value from the proposed solution contains a G or
	    #3 for this genome
	    if($snp_val =~ /^[g3bdvrksnx]$/i)
	      {
		$matched = 1;

		if($label_array->[$relevant_genome_index])
		  {
		    $label_counts->[3]++;

		    $weighted_label_counts->[3] +=
		      1 / $num_possible_states->[$relevant_genome_index];

		    #If this genome was placed here by a real SNP value (not .)
		    if($counted_scores->[$relevant_genome_index])
		      {$real_label_counts->[3]++}
		  }

		$total_counts->[3]++;

		$weighted_total_counts->[3] +=
		  1 / $num_possible_states->[$relevant_genome_index];

		#Push the current genome's SNP data and labels into the G well
		push(@{$new_label_array->[3]},
		     $label_array->[$relevant_genome_index]);
		push(@{$new_relevant_genomes->[3]},
		     $relevant_genomes->[$relevant_genome_index]);
		push(@{$new_counted_scores->[3]},1);
		push(@{$new_num_possible_states->[3]},
		     $num_possible_states->[$relevant_genome_index]);
	      }

	    #If the first snp value from the proposed solution contains a C or
	    #4 for this genome
	    if($snp_val =~ /^[c4bhvymsnx]$/i)
	      {
		$matched = 1;

		if($label_array->[$relevant_genome_index])
		  {
		    $label_counts->[4]++;

		    $weighted_label_counts->[4] +=
		      1 / $num_possible_states->[$relevant_genome_index];

		    #If this genome was placed here by a real SNP value (not .)
		    if($counted_scores->[$relevant_genome_index])
		      {$real_label_counts->[4]++}
		  }

		$total_counts->[4]++;

		$weighted_total_counts->[4] +=
		  1 / $num_possible_states->[$relevant_genome_index];

		#Push the current genome's SNP data and labels into the C well
		push(@{$new_label_array->[4]},
		     $label_array->[$relevant_genome_index]);
		push(@{$new_relevant_genomes->[4]},
		     $relevant_genomes->[$relevant_genome_index]);
		push(@{$new_counted_scores->[4]},1);
		push(@{$new_num_possible_states->[4]},
		     $num_possible_states->[$relevant_genome_index]);
	      }

	    #If the first snp value from the proposed solution contains a gap
	    #(-) or 5 for this genome
	    if($snp_val =~ /^[\-5]$/i)
	      {
		$matched = 1;

		if($label_array->[$relevant_genome_index])
		  {
		    $label_counts->[5]++;

		    $weighted_label_counts->[5] +=
		      1 / $num_possible_states->[$relevant_genome_index];

		    #If this genome was placed here by a real SNP value (not .)
		    if($counted_scores->[$relevant_genome_index])
		      {$real_label_counts->[5]++}
		  }

		$total_counts->[5]++;

		$weighted_total_counts->[5] +=
		  1 / $num_possible_states->[$relevant_genome_index];

		#Push the current genome's SNP data and labels into the gap (-)
		#well
		push(@{$new_label_array->[5]},
		     $label_array->[$relevant_genome_index]);
		push(@{$new_relevant_genomes->[5]},
		     $relevant_genomes->[$relevant_genome_index]);
		push(@{$new_counted_scores->[5]},1);
		push(@{$new_num_possible_states->[5]},
		     $num_possible_states->[$relevant_genome_index]);
	      }
	  }

	#If the SNP character is erroneous
	if(!$matched)
	  {
	    error("Bad SNP character in input file for genome: ",
		  "[$genome_names->[$real_genome_index]] and SNP: ",
		  "[$snp_names->[$snp]]: [$snp_val].\n");
	  }
      }

    ##
    ## Check to make sure the above code worked as expected if this is the
    ## first call.  (We will assume the it works on every subsequent recursive
    ## call.)
    ##

    #If this is the first call and the wells are all empty
    if($first_call && $going_to_recurse &&
       (scalar(@{$new_label_array->[0]}) == 0 &&
	scalar(@{$new_label_array->[1]}) == 0 &&
	scalar(@{$new_label_array->[2]}) == 0 &&
	scalar(@{$new_label_array->[3]}) == 0 &&
	scalar(@{$new_label_array->[4]}) == 0 &&
        scalar(@{$new_label_array->[5]}) == 0))
      {
	#ERROR
	error("The first call did not find any data for SNP[$snp] in the ",
	      "buffer of size: [",
	      scalar(@$label_array),
	      "]!  Either there is a bug in the program or your SNP data ",
	      "file is not correctly formatted.\n");
	exit(8);
      }

    my($dot_node,$a_node,$t_node,$g_node,$c_node,$gap_node);
    #If we're saving a solution tree
    if($do_soln_tree)
      {
	#Create new nodes to be added to the solution tree
	$dot_node = tree->new($snp_names->[$snp] . ": no data (" .
			      "$label_counts->[0]/$total_counts->[0])");
	$a_node   = tree->new($snp_names->[$snp] . ": A (real: " .
			      "$label_counts->[1]/$total_counts->[1], no " .
			      "data: $label_counts->[0]/$total_counts->[0])");
	$t_node   = tree->new($snp_names->[$snp] . ": T (real: " .
			      "$label_counts->[2]/$total_counts->[2], no " .
			      "data: $label_counts->[0]/$total_counts->[0])");
	$g_node   = tree->new($snp_names->[$snp] . ": G (real: " .
			      "$label_counts->[3]/$total_counts->[3], no " .
			      "data: $label_counts->[0]/$total_counts->[0])");
	$c_node   = tree->new($snp_names->[$snp] . ": C (real: " .
			      "$label_counts->[4]/$total_counts->[4], no " .
			      "data: $label_counts->[0]/$total_counts->[0])");
	$gap_node = tree->new($snp_names->[$snp] . ": gap (real: " .
			      "$label_counts->[5]/$total_counts->[5], no " .
			      "data: $label_counts->[0]/$total_counts->[0])");

	#Add nodes to the solution tree
	if($total_counts->[0])
	  {$prtl_soln_tree->addChild($dot_node)}
	if($total_counts->[1])
	  {$prtl_soln_tree->addChild($a_node)}
	if($total_counts->[2])
	  {$prtl_soln_tree->addChild($t_node)}
	if($total_counts->[3])
	  {$prtl_soln_tree->addChild($g_node)}
	if($total_counts->[4])
	  {$prtl_soln_tree->addChild($c_node)}
	if($total_counts->[5])
	  {$prtl_soln_tree->addChild($gap_node)}
      }

    ##
    ## The next major step is to recurse to handle the rest of the SNPs in the
    ## proposed solution, passing along what we've gathered for each well.
    ##

    #If we're not at the end of the solution
    if(scalar(@$proposed_solution))
      {
	##
	## Get the relative scores from the children
	##

	my $children_score = 0;

	#Get the scores from the recursive call
	my($dot_score,$dot_labels,$a_score,$a_labels,$t_score,$t_labels,
	   $g_score,$g_labels,$c_score,$c_labels,$gap_score,$gap_labels);

        #If there were no labeled genomes in any of the other branches/wells
	#(i.e. no other recursive calls will be made), go down this branch to
	#separate the genomes further by the next SNP.  Otherwise, there's no
	#need to traverse this branch in the computation, because the genomes
	#here will travel with the other branches that have had genomes put in
	#them.
        if(scalar(grep {$_} @{$label_counts}[1..5]) == 0)
          {
            #$dot_labels = ($label_counts->[0] ? $label_counts->[0] : 1);

	    #If there are labelled genomes and not all are real & labelled,
	    #recurse with just this node
	    if($label_counts->[0] &&
	       $real_label_counts->[0] != $total_counts->[0])
	      {#($dot_score,$dot_labels) = getRatioResolved($proposed_solution,
		$dot_score = getRatioResolved($proposed_solution,
					      $snp_data_buffer,
					      $new_label_array->[0],
					      $new_relevant_genomes->[0],
					      $scoring_function,
					      $dot_node,
					      $new_counted_scores->[0],
					      $new_num_possible_states->[0],
					      1);
	      }
	    #Else if there are labelled genomes and all are real and labelled
	    elsif($label_counts->[0] &&
	          $total_counts->[0] == $real_label_counts->[0])
	      {
		if($do_soln_tree)
		  {
		    #Add genomes to the solution tree for partial solution
		    #output
		    foreach my $genom
		      (map {($new_label_array->[0]->[$_] ? '* ' : '- ') .
			      $genome_names->[$new_relevant_genomes
					      ->[0]->[$_]]}
		       (0..$#{$new_relevant_genomes->[0]}))
			{$dot_node->addChild(tree->new($genom))}
		  }

                $dot_score = 1;
              }
	    #Else - the score is 0
	    else
	      {
		if($do_soln_tree)
		  {
		    #Add genomes to the solution tree for partial solution
		    #output
		    foreach my $genom
		      (map {($new_label_array->[0]->[$_] ? '* ' : '- ') .
			      $genome_names->[$new_relevant_genomes
					      ->[0]->[$_]]}
		       (0..$#{$new_relevant_genomes->[0]}))
			{$dot_node->addChild(tree->new($genom))}
		  }

		$dot_score = 0;
	      }
          }
	#Else - there will be no recursion with this well and the score is 0
        else
          {
	    if($do_soln_tree)
	      {
		#Add genomes to the solution tree for partial solution output
		foreach my $genom
		  (map {($new_label_array->[0]->[$_] ? '* ' : '- ') .
			  $genome_names->[$new_relevant_genomes
					  ->[0]->[$_]]}
		   (0..$#{$new_relevant_genomes->[0]}))
		    {$dot_node->addChild(tree->new($genom))}
	      }

	    $dot_score = 0;
	  }

	##
	## Recurse for each well to get the score for that well
	##

	$a_score = getRatioResolved($proposed_solution,
				    $snp_data_buffer,
				    (scalar(@{$new_label_array->[1]}) &&
				     scalar(@{$new_label_array->[0]}) ?
				     [@{$new_label_array->[1]},
				      @{$new_label_array->[0]}] :
				     $new_label_array->[1]),
				    (scalar(@{$new_label_array->[1]}) &&
				     scalar(@{$new_label_array->[0]}) ?
				     [@{$new_relevant_genomes->[1]},
				      @{$new_relevant_genomes->[0]}] :
				     $new_relevant_genomes->[1]),
				    $scoring_function,
				    $a_node,
				    (scalar(@{$new_label_array->[1]}) &&
				     scalar(@{$new_label_array->[0]}) ?
				     [@{$new_counted_scores->[1]},
				      @{$new_counted_scores->[0]}] :
				     $new_counted_scores->[1]),
				    undef,
				    1);

	$t_score = getRatioResolved($proposed_solution,
				    $snp_data_buffer,
				    (scalar(@{$new_label_array->[2]}) &&
				     scalar(@{$new_label_array->[0]}) ?
				     [@{$new_label_array->[2]},
				      @{$new_label_array->[0]}] :
				     $new_label_array->[2]),
				    (scalar(@{$new_label_array->[2]}) &&
				     scalar(@{$new_label_array->[0]}) ?
				     [@{$new_relevant_genomes->[2]},
				      @{$new_relevant_genomes->[0]}] :
				     $new_relevant_genomes->[2]),
				    $scoring_function,
				    $t_node,
				    (scalar(@{$new_label_array->[2]}) &&
				     scalar(@{$new_label_array->[0]}) ?
				     [@{$new_counted_scores->[2]},
				      @{$new_counted_scores->[0]}] :
				     $new_counted_scores->[2]),
				    undef,
				    1);

	$g_score = getRatioResolved($proposed_solution,
				    $snp_data_buffer,
				    (scalar(@{$new_label_array->[3]}) &&
				     scalar(@{$new_label_array->[0]}) ?
				     [@{$new_label_array->[3]},
				      @{$new_label_array->[0]}] :
				     $new_label_array->[3]),
				    (scalar(@{$new_label_array->[3]}) &&
				     scalar(@{$new_label_array->[0]}) ?
				     [@{$new_relevant_genomes->[3]},
				      @{$new_relevant_genomes->[0]}] :
				     $new_relevant_genomes->[3]),
				    $scoring_function,
				    $g_node,
				    (scalar(@{$new_label_array->[3]}) &&
				     scalar(@{$new_label_array->[0]}) ?
				     [@{$new_counted_scores->[3]},
				      @{$new_counted_scores->[0]}] :
				     $new_counted_scores->[3]),
				    undef,
				    1);

	$c_score = getRatioResolved($proposed_solution,
				    $snp_data_buffer,
				    (scalar(@{$new_label_array->[4]}) &&
				     scalar(@{$new_label_array->[0]}) ?
				     [@{$new_label_array->[4]},
				      @{$new_label_array->[0]}] :
				     $new_label_array->[4]),
				    (scalar(@{$new_label_array->[4]}) &&
				     scalar(@{$new_label_array->[0]}) ?
				     [@{$new_relevant_genomes->[4]},
				      @{$new_relevant_genomes->[0]}] :
				     $new_relevant_genomes->[4]),
				    $scoring_function,
				    $c_node,
				    (scalar(@{$new_label_array->[4]}) &&
				     scalar(@{$new_label_array->[0]}) ?
				     [@{$new_counted_scores->[4]},
				      @{$new_counted_scores->[0]}] :
				     $new_counted_scores->[4]),
				    undef,
				    1);

	$gap_score = getRatioResolved($proposed_solution,
				      $snp_data_buffer,
				      (scalar(@{$new_label_array->[5]}) &&
				       scalar(@{$new_label_array->[0]}) ?
				       [@{$new_label_array->[5]},
					@{$new_label_array->[0]}] :
				       $new_label_array->[5]),
				      (scalar(@{$new_label_array->[5]}) &&
				       scalar(@{$new_label_array->[0]}) ?
				       [@{$new_relevant_genomes->[5]},
					@{$new_relevant_genomes->[0]}] :
				       $new_relevant_genomes->[5]),
				      $scoring_function,
				      $gap_node,
				      (scalar(@{$new_label_array->[5]}) &&
				       scalar(@{$new_label_array->[0]}) ?
				       [@{$new_counted_scores->[5]},
					@{$new_counted_scores->[0]}] :
				       $new_counted_scores->[5]),
				      undef,
				      1);

	##
	## Calculate the weighted scores obtained from the relative
	## children's scores
	##

	if($label_counts->[0] || $label_counts->[1] ||
	   $label_counts->[2] || $label_counts->[3] ||
	   $label_counts->[4] || $label_counts->[5])
	  {
	    $children_score =
	      ((scalar(grep {$_} @{$label_counts}[1..5]) == 0 ?
		$dot_score : 0) * $label_counts->[0] +

	       #Multiply the ratio of real isolated labelled counts
	       #by the total number of label counts that were put
	       #down that well to get a relative value of how many
	       #labelled genomes at this level of the tree were
	       #isolated by the lower level of the tree.  Include
	       #the number from the pseudowell only if there are
	       #labelled genomes in the real well
	       $a_score   * $label_counts->[1] +
	       $t_score   * $label_counts->[2] +
	       $g_score   * $label_counts->[3] +
	       $c_score   * $label_counts->[4] +
	       $gap_score * $label_counts->[5]) /

		 #Divide the number of isolated real labelled genomes above
		 #by the total number of labelled genomes below to see how
		 #good the answer at the lower level of the tree was
		 ($label_counts->[0] +
		  $label_counts->[1] +
		  $label_counts->[2] +
		  $label_counts->[3] +
		  $label_counts->[4] +
		  $label_counts->[5]);
	  }

	#Overwrite the childrens' score with the worst score.  The only reason
	#we're doing the recursions above is to generate a partial solution
	#tree.  The actual 'worst' score is calculated here (or below for size
	#1 SNP solutions)
	if($scoring_function =~ /^worst/i && $first_call)
	  {$children_score = getWorstRatioResolved([$snp,@$proposed_solution],
						   $snp_data_buffer,
						   $label_array,
						   $relevant_genomes)}

	#Return the children score
	return($children_score);
      }
    else
      {
	##
	## This last step is where the score is actually calculated at each
	## leaf based on the mix of labelled and unlabelled genomes present.
	## It's based on a formula.  The scores are returned to be merged into
	## an average score balanced with the neighboring solution tree leaves.
	##

	#If we're generating a partial solution tree, construct it
	if($do_soln_tree)
	  {
	    #Construct the solution tree for the partial solutions output
	    if($total_counts->[0])
	      {
		#Add genomes to the solution tree for partial solution output
		foreach my $genom
		  (map {($new_label_array->[0]->[$_] ? '* ' : '- ') .
			  $genome_names->[$new_relevant_genomes
					  ->[0]->[$_]]}
		   (0..$#{$new_relevant_genomes->[0]}))
		    {$dot_node->addChild(tree->new($genom))}
	      }

	    if($total_counts->[1])
	      {
		#Add genomes to the solution tree for partial solution output
		foreach my $genom
		  (map {($new_label_array->[1]->[$_] ? '* ' : '- ') .
			  $genome_names->[$new_relevant_genomes
					  ->[1]->[$_]]}
		   (0..$#{$new_relevant_genomes->[1]}))
		  {$a_node->addChild(tree->new($genom))}
		foreach my $genom
		  (map {($new_label_array->[0]->[$_] ? '* ' : '- ') .
			  $genome_names->[$new_relevant_genomes
					  ->[0]->[$_]]}
		   (0..$#{$new_relevant_genomes->[0]}))
		    {$a_node->addChild(tree->new($genom))}
	      }

	    if($total_counts->[2])
	      {
		#Add genomes to the solution tree for partial solution output
		foreach my $genom
		  (map {($new_label_array->[2]->[$_] ? '* ' : '- ') .
			  $genome_names->[$new_relevant_genomes
					  ->[2]->[$_]]}
		   (0..$#{$new_relevant_genomes->[2]}))
		    {$t_node->addChild(tree->new($genom))}
		foreach my $genom
		  (map {($new_label_array->[0]->[$_] ? '* ' : '- ') .
			  $genome_names->[$new_relevant_genomes
					  ->[0]->[$_]]}
		   (0..$#{$new_relevant_genomes->[0]}))
		    {$t_node->addChild(tree->new($genom))}
	      }

	    if($total_counts->[3])
	      {
		#Add genomes to the solution tree for partial solution output
		foreach my $genom
		  (map {($new_label_array->[3]->[$_] ? '* ' : '- ') .
			  $genome_names->[$new_relevant_genomes
					  ->[3]->[$_]]}
		   (0..$#{$new_relevant_genomes->[3]}))
		    {$g_node->addChild(tree->new($genom))}
		foreach my $genom
		  (map {($new_label_array->[0]->[$_] ? '* ' : '- ') .
			  $genome_names->[$new_relevant_genomes
					  ->[0]->[$_]]}
		   (0..$#{$new_relevant_genomes->[0]}))
		    {$g_node->addChild(tree->new($genom))}
	      }

	    if($total_counts->[4])
	      {
		#Add genomes to the solution tree for partial solution output
		foreach my $genom
		  (map {($new_label_array->[4]->[$_] ? '* ' : '- ') .
			  $genome_names->[$new_relevant_genomes
					  ->[4]->[$_]]}
		   (0..$#{$new_relevant_genomes->[4]}))
		    {$c_node->addChild(tree->new($genom))}
		foreach my $genom
		  (map {($new_label_array->[0]->[$_] ? '* ' : '- ') .
			  $genome_names->[$new_relevant_genomes
					  ->[0]->[$_]]}
		   (0..$#{$new_relevant_genomes->[0]}))
		    {$c_node->addChild(tree->new($genom))}
	      }

	    if($total_counts->[5])
	      {
		#Add genomes to the solution tree for partial solution output
		foreach my $genom
		  (map {($new_label_array->[5]->[$_] ? '* ' : '- ') .
			  $genome_names->[$new_relevant_genomes
					  ->[5]->[$_]]}
		   (0..$#{$new_relevant_genomes->[5]}))
		    {$gap_node->addChild(tree->new($genom))}
		foreach my $genom
		  (map {($new_label_array->[0]->[$_] ? '* ' : '- ') .
			  $genome_names->[$new_relevant_genomes
					  ->[0]->[$_]]}
		   (0..$#{$new_relevant_genomes->[0]}))
		    {$gap_node->addChild(tree->new($genom))}
	      }
	  }

	##
	## Calculate the score of the whole solution at this SNP leaf.  Scores
	## at this level will be collected and averaged upon return of this
	## last level of recursion
	##

	my($normal_score);

	if($scoring_function =~ /^orig/i || !$first_call)
	  {$normal_score = getOriginalScore($label_counts,
					    $total_counts)}
	elsif($scoring_function =~ /^worst/i && $first_call)
	  {$normal_score = getWorstRatioResolved([$snp],
						 $snp_data_buffer,
						 $label_array,
						 $relevant_genomes)}

	#Return the leaves' score
	return($normal_score);
      }
  }








sub getWorstRatioResolved
  {
    use strict;

    my $proposed_solution = $_[0];
    my $snp_data_buffer   = $_[1];  #Array of SNP strings for each genome
    my $label_array       = $_[2];  #Array of genome labels indexed by
                                      #genome
    my $relevant_genomes  = $_[3];  #Array of genome indexes to consider

    #If the well was empty, return 0
    if(scalar(@$label_array) == 0)
      {return(0)}

    my($matched);
    my $relevant_genome_index = -1;
    my $state_hash            = {};

    ##
    ## We're going to build the solution tree from most defined states to least
    ## defined states and when we are faced with a decision of which branch to
    ## throw a genome down due to an ambiguous SNP, we'll throw it down the one
    ## that causes the worst score given the knowledge at that level of the
    ## tree (note, this may not result in the worst score possible)
    ##

    print STDERR ("DEBUG: Call to getWorstRatioResolved for proposed SNP ",
		  "solution [",join(',',@$proposed_solution),"].\n")
      if($DEBUG);

    #For each genome, sorted by number of states it can possibly be in given
    #the ambiguous nucleotides, determine the worst possible combo of SNP vals
    foreach my $relevant_genome_index
      (sort {my $real_a = $relevant_genomes->[$a];
	     my $real_b = $relevant_genomes->[$b];
	     my $a_mult = 1;
	     map {$a_mult *= getNumStates(getSNP($snp_data_buffer,$real_a,$_))}
	       @$proposed_solution;
	     my $b_mult = 1;
	     map {$b_mult *= getNumStates(getSNP($snp_data_buffer,$real_b,$_))}
	       @$proposed_solution;
	     $a_mult <=> $b_mult} (0..$#$relevant_genomes))
      {
	#Indexes are stored in the relevant_genomes array of where SNPs are in
	#the snp_data_buffer.  However, the relevant_genomes array only has the
	#indexes of the genomes which contain actual information (in other
	#words, if all the SNPs in a particular genome have dots for all SNPs,
	#the genome is not considered).
	my $real_genome_index = $relevant_genomes->[$relevant_genome_index];

	print STDERR ("DEBUG: Processing Genome/SNP Combo: ",
		      "[$genome_names->[$real_genome_index] / ",
		      join('',
			   map {getSNP($snp_data_buffer,$real_genome_index,$_)}
			   @$proposed_solution),"].\n") if($DEBUG);

	#Keep track of the worst combination of SNP values in a string (/key)
	my $combo_str = '';
	my $level = 0; #Basically a SNP count
	#For each snp index
	###Can't sort because between genomes, the combo_str needs to be formed
	###in the same order, so I commented out the comment below and the sort
	###code:
	###, sorted by increasing number of possibile states
	foreach my $snp
	  (#sort {getNumStates(getSNP($snp_data_buffer,$real_genome_index,$a))
		  #<=> getNumStates(getSNP($snp_data_buffer,$real_genome_index,
					   #$b))}
	   @$proposed_solution)
	  {
	    $level++;

	    if(scalar(grep {!exists($state_hash->{$level}->{$_}) ||
			      !defined($state_hash->{$level}->{$_}
				       ->{TOTAL_COUNT}) ||
					 $state_hash->{$level}->{$_}
					   ->{TOTAL_COUNT} eq ''}
		      keys(%{$state_hash->{$level}})))
	      {
		my @err =
		  grep {!exists($state_hash->{$level}->{$_}) ||
			  !defined($state_hash->{$level}->{$_}->{TOTAL_COUNT})}
		    keys(%{$state_hash->{$level}});
		error("We have apparently acquired a bad combo string in our ",
		      "state hash: [",join(',',@err),"].") if($DEBUG);
	      }

	    #Get the current SNP's value for this genome
	    my $snp_val .= getSNP($snp_data_buffer,$real_genome_index,$snp);

	    my $num_states = getNumStates($snp_val);

	    $matched = 0;

	    if($num_states == 1)
	      {
		if($snp_val =~ /^[a1]$/i)
		  {$combo_str .= 'a'}
		elsif($snp_val =~ /^[t2]$/i)
		  {$combo_str .= 't'}
		elsif($snp_val =~ /^[g3]$/i)
		  {$combo_str .= 'g'}
		elsif($snp_val =~ /^[c4]$/i)
		  {$combo_str .= 'c'}
		elsif($snp_val =~ /^[\-5]$/i)
		  {$combo_str .= '-'}
		else
		  {error("Bad SNP value encountered: [$snp_val].")}
	      }
	    elsif($num_states == 2)
	      {
		if($snp_val =~ /^r$/i)
		  {$combo_str .=
		     (sort {cmpCombo($state_hash->{$level},
				     $combo_str,
				     $label_array->[$relevant_genome_index],
				     $a,$b)} ('a','g'))[0]}
		elsif($snp_val =~ /^y$/i)
		  {$combo_str .=
		     (sort {cmpCombo($state_hash->{$level},
				     $combo_str,
				     $label_array->[$relevant_genome_index],
				     $a,$b)} ('c','t'))[0]}
		elsif($snp_val =~ /^k$/i)
		  {$combo_str .=
		     (sort {cmpCombo($state_hash->{$level},
				     $combo_str,
				     $label_array->[$relevant_genome_index],
				     $a,$b)} ('g','t'))[0]}
		elsif($snp_val =~ /^m$/i)
		  {$combo_str .=
		     (sort {cmpCombo($state_hash->{$level},
				     $combo_str,
				     $label_array->[$relevant_genome_index],
				     $a,$b)} ('a','c'))[0]}
		elsif($snp_val =~ /^s$/i)
		  {$combo_str .=
		     (sort {cmpCombo($state_hash->{$level},
				     $combo_str,
				     $label_array->[$relevant_genome_index],
				     $a,$b)} ('g','c'))[0]}
		elsif($snp_val =~ /^w$/i)
		  {$combo_str .=
		     (sort {cmpCombo($state_hash->{$level},
				     $combo_str,
				     $label_array->[$relevant_genome_index],
				     $a,$b)} ('a','t'))[0]}
	      }
	    elsif($num_states == 3)
	      {
		if($snp_val =~ /^b$/i)
		  {$combo_str .=
		     (sort {cmpCombo($state_hash->{$level},
				     $combo_str,
				     $label_array->[$relevant_genome_index],
				     $a,$b)} ('c','g','t'))[0]}
		elsif($snp_val =~ /^d$/i)
		  {$combo_str .=
		     (sort {cmpCombo($state_hash->{$level},
				     $combo_str,
				     $label_array->[$relevant_genome_index],
				     $a,$b)} ('a','g','t'))[0]}
		elsif($snp_val =~ /^h$/i)
		  {$combo_str .=
		     (sort {cmpCombo($state_hash->{$level},
				     $combo_str,
				     $label_array->[$relevant_genome_index],
				     $a,$b)} ('a','c','t'))[0]}
		elsif($snp_val =~ /^v$/i)
		  {$combo_str .=
		     (sort {cmpCombo($state_hash->{$level},
				     $combo_str,
				     $label_array->[$relevant_genome_index],
				     $a,$b)} ('a','c','g'))[0]}
	      }
	    elsif($num_states == 4)
	      {
		if($snp_val =~ /^[nx]$/i)
		  {$combo_str .=
		     (sort {cmpCombo($state_hash->{$level},
				     $combo_str,
				     $label_array->[$relevant_genome_index],
				     $a,$b)} ('a','t','g','c'))[0]}
	      }
	    elsif($num_states == 5)
	      {
		if($snp_val eq '.')
		  {$combo_str .=
		     (sort {cmpCombo($state_hash->{$level},
				     $combo_str,
				     $label_array->[$relevant_genome_index],
				     $a,$b)} ('a','t','g','c','-'))[0]}
	      }
	    else
	      {error("Bad SNP value encountered: [$snp_val].")}

	    #Keep track of all the counts of genomes for each state
	    if($label_array->[$relevant_genome_index])
	      {$state_hash->{$level}->{$combo_str}->{LABEL_COUNT}++}
	    else
	      {$state_hash->{$level}->{$combo_str}->{UNLABEL_COUNT}++}

	    $state_hash->{$level}->{$combo_str}->{TOTAL_COUNT}++;

	    print STDERR ("DEBUG: Incrementing state counts for state: ",
			  "[$combo_str].\nDEBUG: New total count: [",
			  $state_hash->{$level}->{$combo_str}->{TOTAL_COUNT},
			  "].\n") if($DEBUG);
	  }
      }

    my $sol_size = scalar(@$proposed_solution);
    my $normal_score =
      getStatesScore([map {$state_hash->{$sol_size}->{$_}->{LABEL_COUNT}}
		      #sort {$a cmp $b}
		      keys(%{$state_hash->{$sol_size}})],
		     [map {$state_hash->{$sol_size}->{$_}->{TOTAL_COUNT}}
		      #sort {$a cmp $b}
		      keys(%{$state_hash->{$sol_size}})]);

    if($DEBUG)
      {
	print STDERR ("DEBUG: STATES WITH SCORE [$normal_score]...\n");
	foreach my $combo (keys(%{$state_hash->{$sol_size}}))
	  {
	    print STDERR ("DEBUG: Combo: [$combo] Labels: [",
			  $state_hash->{$sol_size}->{$combo}->{LABEL_COUNT},
			  "] Total: [",
			  $state_hash->{$sol_size}->{$combo}->{TOTAL_COUNT},
			  "].\n");
	  }
      }

    #Return the leaves' score
    return($normal_score);
  }

sub cmpCombo
  {
    my $level_state_hash = $_[0];
    my $combo_str        = $_[1];
    my $is_labeled       = $_[2];
    my $a                = $_[3];
    my $b                = $_[4];

    print STDERR ("DEBUG: Call to cmpCombo with combo string [$combo_str], ",
		  "is_labeled [$is_labeled], a [$a], b [$b].\n",
		  "DEBUG: State Hash Keys: [",
		  join(',',keys(%$level_state_hash)),"].\n",
		  "DEBUG: State Hash Values: [",
		  join(',',map {$level_state_hash->{$_}->{TOTAL_COUNT}} keys(%$level_state_hash)),"].\n")
      if($DEBUG);

    if(scalar(grep {!exists($level_state_hash->{$_}) ||
		      !defined($level_state_hash->{$_}->{TOTAL_COUNT}) ||
			$level_state_hash->{$_}->{TOTAL_COUNT} eq ''}
	      keys(%{$level_state_hash})))
      {
	my @err =
	  grep {!exists($level_state_hash->{$_}) ||
		  !defined($level_state_hash->{$_}->{TOTAL_COUNT})}
	    keys(%{$level_state_hash});
	error("We have apparently acquired a bad combo string in our ",
	      "state hash: [",join(',',@err),"].") if($DEBUG);
      }

    #If this is a labeled genome (the ordering is different)
    if($is_labeled)
      {
	return(#If combo a exists and its ratio is 1 and...
	       exists($level_state_hash->{$combo_str.$a}) &&
	       ($level_state_hash->{$combo_str.$a}->{LABEL_COUNT} /
		$level_state_hash->{$combo_str.$a}->{TOTAL_COUNT}) == 1 &&
	       #combo b doesn't exist or is less than 1
	       (!exists($level_state_hash->{$combo_str.$b}) ||
	        ($level_state_hash->{$combo_str.$b}->{LABEL_COUNT} /
		 $level_state_hash->{$combo_str.$b}->{TOTAL_COUNT}) < 1) ?
	       #then combo b comes before combo a (result is 1)
	       1 : #Else if combo b exists and its ratio is 1 and...
	       (exists($level_state_hash->{$combo_str.$b}) &&
		($level_state_hash->{$combo_str.$b}->{LABEL_COUNT} /
		 $level_state_hash->{$combo_str.$b}->{TOTAL_COUNT}) == 1 &&
		#combo a doesn't exist or its ratio is less than 1
		(!exists($level_state_hash->{$combo_str.$a}) ||
		 ($level_state_hash->{$combo_str.$a}->{LABEL_COUNT} /
		  $level_state_hash->{$combo_str.$a}->{TOTAL_COUNT}) < 1) ?
		#then combo a comes before combo b (result is -1)
		-1 :
		#Else if both combos exist and are 1
		(exists($level_state_hash->{$combo_str.$a}) &&
		 ($level_state_hash->{$combo_str.$a}->{LABEL_COUNT} /
		  $level_state_hash->{$combo_str.$a}->{TOTAL_COUNT}) == 1 &&
		 exists($level_state_hash->{$combo_str.$b}) &&
		 ($level_state_hash->{$combo_str.$b}->{LABEL_COUNT} /
		  $level_state_hash->{$combo_str.$b}->{TOTAL_COUNT}) == 1 ?
		 #Then order by descending number of genomes or...
		 ($level_state_hash->{$combo_str.$b}->{TOTAL_COUNT} <=>
		  $level_state_hash->{$combo_str.$a}->{TOTAL_COUNT} ||
		  #order randomly
		  (int(rand(2)) ? -1 : 1)) :
		 #Else, everything move on to the next set of sorting params
		 0)) ||
	       #Order by existing to not existing combos or...
	       (exists($level_state_hash->{$combo_str.$b}) <=>
	        exists($level_state_hash->{$combo_str.$a}) ||
	        #If both combos exist (ass. bec. passed thru above & 1 exists)
		(exists($level_state_hash->{$combo_str.$a}) ?
		#Pass it down to the next set of sorting params
		0 : #Else (bec. neither combo exists) order randomly
		(int(rand(2)) ? -1 : 1))) ||
	       #Now everything exists and has a ratio less than 1, so...
	       #order by ascending ratio difference (when this genome is added
	       #to each state) or (if ratio differences are the same)...
	       ((((($level_state_hash->{$combo_str.$a}->{LABEL_COUNT} + 1)**2 /
		   ($level_state_hash->{$combo_str.$a}->{TOTAL_COUNT} + 1)) -
		  ($level_state_hash->{$combo_str.$a}->{LABEL_COUNT}**2 /
		   $level_state_hash->{$combo_str.$a}->{TOTAL_COUNT}))) <=>
	        (((($level_state_hash->{$combo_str.$b}->{LABEL_COUNT} + 1)**2 /
		   ($level_state_hash->{$combo_str.$b}->{TOTAL_COUNT} + 1)) -
		  ($level_state_hash->{$combo_str.$b}->{LABEL_COUNT}**2 /
		   $level_state_hash->{$combo_str.$b}->{TOTAL_COUNT})))) ||
	       #order by descending number of unlabeled genomes or...
	       ($level_state_hash->{$combo_str.$b}->{UNLABEL_COUNT} <=>
		$level_state_hash->{$combo_str.$a}->{UNLABEL_COUNT}) ||
	       #order randomly
	       (int(rand(2)) ? -1 : 1));
      }
    else
      {
	return(#Order by existing to non-existing or...
	       exists($level_state_hash->{$combo_str.$b}) <=>
	       exists($level_state_hash->{$combo_str.$a}) ||
	       #If neither exist
	       (!exists($level_state_hash->{$combo_str.$a}) ?
	        #Order randomly, else pass on to the next set of sorting params
		(int(rand(2)) ? -1 : 1) : 0) ||
	       #Order by descending ratio difference (when this genome is added
	       #to each state) or (if ratio differences are the same)...
	       (((($level_state_hash->{$combo_str.$b}->{LABEL_COUNT}**2 /
		   $level_state_hash->{$combo_str.$b}->{TOTAL_COUNT}) -
		  ($level_state_hash->{$combo_str.$b}->{LABEL_COUNT}**2 /
		   ($level_state_hash->{$combo_str.$b}->{TOTAL_COUNT} + 1))))
		<=>
	        ((($level_state_hash->{$combo_str.$a}->{LABEL_COUNT}**2 /
		   $level_state_hash->{$combo_str.$a}->{TOTAL_COUNT}) -
		  ($level_state_hash->{$combo_str.$a}->{LABEL_COUNT}**2 /
		   ($level_state_hash->{$combo_str.$a}->{TOTAL_COUNT} + 1)))))
	       ||
	       #Order by descending number of labeled genomes or (if same)...
	       $level_state_hash->{$combo_str.$b}->{LABEL_COUNT} <=>
	       $level_state_hash->{$combo_str.$a}->{LABEL_COUNT} ||
	       #Order randomly
	       (int(rand(2)) ? -1 : 1)
	      );
      }
  }

sub getOriginalScore
  {
    my $label_counts = $_[0];
    my $total_counts = $_[1];

    my $score = 0;
    my $total = $label_counts->[0];
    #If there are things in the "no data" well and no labelled samples in all
    #the other wells, base the score on the "no data" well
    if($total_counts->[0] && scalar(grep {$_} @{$label_counts}[1..5]) == 0)
      {
	$score = $label_counts->[0] *
	  ($label_counts->[0] / $total_counts->[0]);
      }
    else
      {
	foreach my $well (1..5)
	  {
	    #Add the total label counts for this well and the pseudowell
	    #multiplied by their ratio of the total number of counts
	    $score +=
	      #Don't need to test the real well because that's done at the
	      #if at the end of this equation
	      $label_counts->[$well] *
		($label_counts->[$well] /
		 ($total_counts->[$well] +
		  #Penalize the score by adding the number of
		  #unlabeled genomes in the dot well to the total
		  ($total_counts->[0] - $label_counts->[0])))
		  if($total_counts->[$well]);

	    $total += $label_counts->[$well];
	  }
      }

    #Normalize the score using the total number of genomes in all wells
    my $normal_score = 0;
    $normal_score = $score / $total
      if($total);

    return($normal_score);
  }

#Assumes that all states are unambiguous
sub getStatesScore
  {
    my $state_hash = $_[0];
    my $label_counts = $_[0]; #Array of counts of labels in each state
    my $total_counts = $_[1]; #Array of total number of genomes in each state

    #Calculate the score I would get if all data was real
    my $score = 0;
    my $total = 0;
    foreach my $state_index (0..$#$label_counts)
      {
	$score += $label_counts->[$state_index]**2 /
	  $total_counts->[$state_index]
	    if($total_counts->[$state_index]);
	$total += $label_counts->[$state_index];
      }

    return($score / $total);
  }

sub getNumStates
  {
    my $snp_val = $_[0];

    if($snp_val =~ /^[atgc\-12345]$/i)
      {return(1)}
    elsif($snp_val =~ /^[rykmsw]$/i)
      {return(2)}
    elsif($snp_val =~ /^[bdhv]$/i)
      {return(3)}
    elsif($snp_val =~ /^[nx]$/i)
      {return(4)}
    elsif($snp_val eq '.')
      {return(5)}
  }



#This subroutine optimizes the SNPs and returns an array of SNP sets that are
#informationally equivalent (in the context of genome resolving power).  An
#example of such an array is: [[2,4,8],[1,3],[5,6,7]].  SNPs 2, 4, and 8 are
#equivalent.  Only one of them needs to be tested to see if it's a solution.
#If 2 is a solution, then 4 and 8 are as well, however note that their values
#may be different (although the pattern of their values is the same).
sub optimizeSNPs
  {
    my $snp_names       = $_[0];
    my $genome_names    = $_[1];
    my $snp_data_buffer = $_[2];

    verbose("Optimizing SNPs.");

    my $matched = 0;
    my $sorted_genome_sets = [];
    my $equivalent_snps = {};
    foreach my $snp_index (0..(scalar(@$snp_names) - 1))
      {
	#Since masking due to haplotype awareness can eliminate SNP value
	#variation, make sure a SNP is still a SNP by seeing if the organisms
	#have multiple values other than the ignore character.
	my $snp_check = {};

	#Separate all the genomes based on the current SNP's values
	my $current_genome_sets = [[],[],[],[],[],[]];
	foreach my $genome_index (0..(scalar(@$genome_names) - 1))
	  {
	    my $snp_val = getSNP($snp_data_buffer,$genome_index,$snp_index);
	    $matched = 0;

	    if($snp_val eq '.')
	      {
		$matched = 1;
		push(@{$current_genome_sets->[0]},$genome_index);
	      }
	    else
	      {
		#Make sure there are multiple REAL SNP values
		$snp_check->{$snp_val}++;

		if($snp_val =~ /^[a1dhvrmwnx]$/i)
		  {
		    $matched = 1;
		    push(@{$current_genome_sets->[1]},$genome_index);
		  }
		if($snp_val =~ /^[t2bdhykwnx]$/i)
		  {
		    $matched = 1;
		    push(@{$current_genome_sets->[2]},$genome_index);
		  }
		if($snp_val =~ /^[g3bdvrksnx]$/i)
		  {
		    $matched = 1;
		    push(@{$current_genome_sets->[3]},$genome_index);
		  }
		if($snp_val =~ /^[c4bhvymsnx]$/i)
		  {
		    $matched = 1;
		    push(@{$current_genome_sets->[4]},$genome_index);
		  }
		if($snp_val =~ /^[\-5]$/i)
		  {
		    $matched = 1;
		    push(@{$current_genome_sets->[5]},$genome_index);
		  }
	      }

	    #If the SNP character is erroneous
	    if(!$matched)
	      {
		delete($snp_check->{$snp_val});
		error("Bad SNP character in input file for genome: ",
		      "[$genome_names->[$genome_index]] and SNP: ",
		      "[$snp_names->[$snp_index]]: [$snp_val].");
	      }
	  }

	if(scalar(keys(%$snp_check)) <= 1)
	  {
	    verbose("This SNP has lost its variability (probably due to ",
		    "haplotype awareness masking or poor data input) and ",
		    "will not be considered: [$snp_names->[$snp_index]].");
	    next;
	  }

	#Sort the groups of genomes by the value of the first genome index
	#(i.e. the smallest genome index) in each group.  This makes it faster
	#to compare the current grouping produced by the current SNP with
	#groupings produced by other SNPs.
	@$current_genome_sets = sort {$a->[0] <=> $b->[0]}
	  grep {defined($_) && scalar(@$_)} @$current_genome_sets;

	if(scalar(@$sorted_genome_sets) == 0)
	  {
	    #Push the current genome sets array ref onto the empty sorted
	    #genome sets array
	    push(@$sorted_genome_sets,$current_genome_sets);
	    #Make the current genome set array reference, the key to a hash
	    #containing arrays of SNP indexes that created the sets
	    $equivalent_snps->{$current_genome_sets} = [$snp_index];
	  }
	else
	  {
	    ##
	    ## Put the next genome set (made with the current SNP) onto the
	    ## sorted genome sets array (in order) and store the SNP with the
	    ## appropriate array reference key (if the current genome set was
	    ## equal to one already on the sorted genome sets array, the
	    ## current genome set will not be added to the sorted array)
	    ##

	    my $not_equal = 0;  #0 means 'left value is equal to right value'
	                        #-1 means 'left value is less than right value'
	                        #1 means 'left value is greater than rt. value'
	    my $bottom    = 0;
	    my $top       = scalar(@$sorted_genome_sets) - 1; #guranteed >= 1
	    my $position  = int($top / 2);

	    while(1)
	      {
		$position = $bottom + int(($top - $bottom) / 2);
		my $seen_genome_pattern = $sorted_genome_sets->[$position];

		#Start out assuming they are equal
		$not_equal = 0;
		#For each well/set
		foreach my $set (0..((scalar(@$seen_genome_pattern) <
				      scalar(@$current_genome_sets) ?
				      scalar(@$seen_genome_pattern) :
				      scalar(@$current_genome_sets)) - 1))
		  {
		    #Make sure the genome indexes are equal
		    foreach my $genome_index_index
		      (0..((scalar(@{$seen_genome_pattern->[$set]}) <
			    scalar(@{$current_genome_sets->[$set]}) ?
			    scalar(@{$seen_genome_pattern->[$set]}) :
			    scalar(@{$current_genome_sets->[$set]})) - 1))
			{
			  if($current_genome_sets->[$set]
			     ->[$genome_index_index] <
			     $seen_genome_pattern->[$set]
			     ->[$genome_index_index])
			    {$not_equal = -1}
			  elsif($current_genome_sets->[$set]
			     ->[$genome_index_index] >
			     $seen_genome_pattern->[$set]
			     ->[$genome_index_index])
			    {$not_equal = 1}

			  #Last if they're not equal (i.e. continue to prove
			  #they're equal if they're equal so far)
			  last if($not_equal);
			}

		    #If they are equal so far, base equality on size where
		    #(larger is "less than" smaller)
		    if($not_equal == 0)
		      {
			$not_equal = scalar(@{$seen_genome_pattern->[$set]})
			  <=> scalar(@{$current_genome_sets->[$set]});
		      }

                    #Last if they're not equal (i.e. continue to prove they're
                    #equal if they're equal so far)
		    last if($not_equal);
		  }

                #Make sure they're equal in size if equal otherwise
                if($not_equal == 0)
		  {$not_equal = scalar(@$seen_genome_pattern) <=>
		     scalar(@$current_genome_sets)}

		#If they are equal or the search is done (and none were equal)
		if($not_equal == 0 || $bottom == $top)
		  {
		    if($not_equal == 1 && $position &&
		       $top != scalar(@$sorted_genome_sets) - 1)
		      {
			#Increment the position and set equal to "less than"
			#because equal == 1 means that the position is larger
			#than everything
			$position++;
			$not_equal = -1;
		      }
		    last;
		  }
                elsif($bottom > $top)
                  {
		    error("Log(n) search of genome sets has encountered an ",
			  "unexplained error.  The search has extended past ",
			  "the known search space.  Please report this error ",
			  "to the author: [BOTTOM: $bottom TOP: $top TOTAL: ",
			  scalar(@$sorted_genome_sets) - 1,
			  "].");
		    exit(3);
		  }

                if($not_equal == -1)
                  {
		    $top = $position - ($position == $bottom ? 0 : 1);
		  }
                elsif($not_equal == 1)
                  {
		    $bottom = $position + ($position == $top ? 0 : 1);
		  }
	      }

	    #If the current_genome_sets is less than anything seen so far,
	    #Push is onto the end of the sorted_genome_sets
	    if($not_equal == 1)
	      {
                verbose(1,
			"SNP: [$snp_names->[$snp_index]] is being appended ",
		        "at position: [",scalar(@$sorted_genome_sets),"].");

		push(@$sorted_genome_sets,$current_genome_sets);
		$equivalent_snps->{$current_genome_sets} = [$snp_index];
	      }
	    elsif($not_equal == -1)
	      {
                verbose(1,
			"SNP: [$snp_names->[$snp_index]] is being inserted ",
		        "at position: [$position].");

		splice(@$sorted_genome_sets,$position,0,$current_genome_sets);
		$equivalent_snps->{$current_genome_sets} = [$snp_index];
	      }
	    else
	      {
                verbose(1,
			"SNP: [$snp_names->[$snp_index]] is being added to ",
		        "position: [$position] with SNP: [",
			$snp_names
			->[$equivalent_snps
			   ->{$sorted_genome_sets->[$position]}->[0]],
			"].");

		error("Invalid sorted genome sets position: [$position].\n",
		      "Please report this error to the author.")
		  if($position == scalar(@$sorted_genome_sets));

		push(@{$equivalent_snps
			 ->{$sorted_genome_sets
			    ->[($position == scalar(@$sorted_genome_sets) ?
				($position - 1) : $position)]}},
		     $snp_index);
	      }
	  }
      }

    if(scalar(keys(%$equivalent_snps)) == 0)
      {warning("There is no remaining SNP data after optimization.  This ",
	       "could mean that the input SNP data was either invalid or ",
	       "haplotype awareness was turned on and the data is extremely ",
	       "divergent in the region of the current node of the tree.")}

    #Sort the array reference keys based on the first SNP ID in each group of
    #equivalent SNPs, then eliminate the array reference keys entirely to
    #simply return an array of equivalent SNP ID arrays
    if(wantarray)
      {return(map {$equivalent_snps->{$_}}
	      sort {$equivalent_snps->{$a}->[0] <=>
		      $equivalent_snps->{$b}->[0]}
	      keys(%$equivalent_snps))}
    return([map {$equivalent_snps->{$_}}
	    sort {$equivalent_snps->{$a}->[0] <=>
		    $equivalent_snps->{$b}->[0]}
	    keys(%$equivalent_snps)]);
  }



##
## Subroutine that prints warnings with a leader string
##
sub verbose
  {
    return(0) unless($verbose);

    #Read in the first argument and determine whether it's part of the message
    #or a value for the overwrite flag
    my $overwrite_flag = $_[0];

    #If a flag was supplied as the first parameter (indicated by a 0 or 1 and
    #more than 1 parameter sent in)
    if(scalar(@_) > 1 && ($overwrite_flag eq '0' || $overwrite_flag eq '1'))
      {shift(@_)}
    else
      {$overwrite_flag = 0}

    #Read in the message
    my $verbose_message = join('',@_);

    $overwrite_flag = 1 if(!$overwrite_flag && $verbose_message =~ /\r/);

    #Initialize globals if not done already
    $main::last_verbose_size  = 0 if(!defined($main::last_verbose_size));
    $main::last_verbose_state = 0 if(!defined($main::last_verbose_state));
    $main::verbose_warning    = 0 if(!defined($main::verbose_warning));

    #Determine the message length
    my($verbose_length);
    if($overwrite_flag)
      {
	$verbose_message =~ s/\r$//;
	if(!$main::verbose_warning && $verbose_message =~ /\n|\t/)
	  {
	    warning("Hard returns and tabs cause overwrite mode to not work ",
		    "properly.");
	    $main::verbose_warning = 1;
	  }
      }
    else
      {chomp($verbose_message)}

    if(!$overwrite_flag)
      {$verbose_length = 0}
    elsif($verbose_message =~ /\n([^\n]*)$/)
      {$verbose_length = length($1)}
    else
      {$verbose_length = length($verbose_message)}

    #Overwrite the previous verbose message by appending spaces just before the
    #first hard return in the verbose message IF THE VERBOSE MESSAGE DOESN'T
    #BEGIN WITH A HARD RETURN.  However note that the length stored as the
    #last_verbose_size is the length of the last line printed in this message.
    if($verbose_message =~ /^([^\n]*)/ && $main::last_verbose_state &&
       $verbose_message !~ /^\n/)
      {
	my $append = ' ' x ($main::last_verbose_size - length($1));
	unless($verbose_message =~ s/\n/$append\n/)
	  {$verbose_message .= $append}
      }

    #If you don't want to overwrite the last verbose message in a series of
    #overwritten verbose messages, you can begin your verbose message with a
    #hard return.  This tells verbose() to not overwrite the last line that was
    #printed in overwrite mode.

    #Print the message to standard error
    print STDERR ($verbose_message,
		  ($overwrite_flag ? "\r" : "\n"));

    #Record the state
    $main::last_verbose_size  = $verbose_length;
    $main::last_verbose_state = $overwrite_flag;

    #Return success
    return(0);
  }

##
## Subroutine that prints warnings with a leader string
##
sub verboseOLD
  {
    return(0) unless($verbose);

    #Read in the first argument and determine whether it's part of the message
    #or a value for the overwrite flag
    my $overwrite_flag = $_[0];

    #If a flag was supplied as the first parameter (indicated by a 0 or 1 and
    #more than 1 parameter sent in)
    if(scalar(@_) > 0 && ($overwrite_flag eq '0' || $overwrite_flag eq '1'))
      {shift(@_)}
    else
      {$overwrite_flag = 0}

    #Read in the message
    my $verbose_message = join('',@_);

    $overwrite_flag = 1 if($overwrite_flag ne '0' &&
			   $verbose_message =~ /\r$/);

    #Initialize globals if not done already
    $main::last_verbose_size  = 0 if(!defined($main::last_verbose_size));
    $main::last_verbose_state = 0 if(!defined($main::last_verbose_state));
    $main::verbose_warning    = 0 if(!defined($main::verbose_warning));

    #Determine the message length
    my($verbose_length);
    if($overwrite_flag)
      {
	$verbose_message =~ s/\r$//;
	if(!$main::verbose_warning && $verbose_message =~ /\t/)
	  {
	    warning("Tabs cause overwrite mode to not work properly.");
	    $main::verbose_warning = 1;
	  }
      }
    else
      {chomp($verbose_message)}

    if($verbose_message =~ /\n([^\n]+)$/)
      {$verbose_length = length($1)}
    else
      {$verbose_length = length($verbose_message)}

    #Print the message to standard error
    print STDERR (($main::last_verbose_state ? "\n" : ''),
		  $verbose_message,
		  ($main::last_verbose_state ?
		   ' ' x ($main::last_verbose_size - $verbose_length) : ''),
		  ($overwrite_flag ? "\r" : "\n"));

    #Record the state
    $main::last_verbose_size  = $verbose_length;
    $main::last_verbose_state = $overwrite_flag;

    #Return success
    return(0);
  }


sub getCommand
  {
    my $perl_path_flag = $_[0];

    my $script = $0;
    $script =~ s/^.*\/([^\/]+)$/$1/;

    my $arguments = [@$preserve_args];
    foreach my $arg (@$arguments)
      {if($arg =~ /(?<!\/)\s/)
	 {$arg = '"' . $arg . '"'}}

    my($command);
    if($perl_path_flag)
      {
	$command = `which $^X`;
	chomp($command);
	$command .= ' ';
      }
    $command .= join(' ',($0,@$arguments));

    #Note, this sub doesn't add any redirected files in or out

    return($command);
  }


#This subroutine represents code copied from statSNPSTI.pl which calculates the
#maximum number of independent solutions (i.e. solutions which don't share any
#SNPs.  This uses a greedy heuristic to calculate the maximum, so it's not 100%
#accurate
sub numIndepSolns
  {
    my @two_d_snp_array = @_;
    my $snp_usage = {};

    #Determine the SNP usage
    foreach my $solution (@two_d_snp_array)
      {
	foreach my $snp_index (@$solution)
	  {$snp_usage->{$snp_index}++}
      }

    #Sort the solutions in the 2D SNP array based on increasing SNP usage
    my @sorted_solutions =
      sort {sum(map {$snp_usage->{$_}} @$a) <=>
	      sum(map {$snp_usage->{$_}} @$b)}
	@two_d_snp_array;

    #Go through the sorted array and push solutions onto the independent
    #solutions array when all its SNPs are "unseen"
    my(@independent_solutions);
    my $seen_snps = {};
    while(scalar(@sorted_solutions))
      {
	#If any of the SNPs in the next solution have already been added in a
	#solution to the independent solutions array
	if(grep {exists($seen_snps->{$_})} @{$sorted_solutions[0]})
	  {shift(@sorted_solutions)}
	else
	  {
	    #Add the new solution with all unseen SNPs to the independent
	    #solutions array
	    push(@independent_solutions,shift(@sorted_solutions));

	    #Mark the SNPs in the new solution as seen
	    foreach my $added_snp (@{$independent_solutions[-1]})
	      {$seen_snps->{$added_snp} = 1}
	  }
      }

    return(scalar(@independent_solutions));
  }


sub sum
  {
    my $sum = 0;
    foreach(@_)
      {$sum += $_}
    return($sum);
  }
