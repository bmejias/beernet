<?php
require("../functions.php");

makeHeader( "Transreal Initiative - Challenges",
			"Transreal Initiative",
			"Challenges",
			"../");
trealMenu("challenges");
?>

<div id="maincontent">

<h2>Challenges for Real-World Computing</h2>

<p><strong>Written by Peter Van Roy in concertation with the TRANSREAL
partners</br> Jan. 2011</strong></p>

<p> This document is part of the TRANSREAL proposal for an FET Flagship
that was submitted in Dec. 2010. We summarize the main challenges in the three 
areas of the proposal:</p>

<ol>

<li> <a href="#elasticity">Challenges in elastic and distributed computing.</a></li>

<li> <a href="#data">Challenges in data processing and machine learning.</a></li>

<li> <a href="#application">Application grand challenges in real-world computing.</a></li>

</ol>

<p> These challenges are highly interdisciplinary.  The two subjects of 
distributed computing and machine learning and the many areas of domain 
expertise must be combined.  The TRANSREAL proposal was not accepted for 
reasons independent of its technical vision (which was highly praised by the 
evaluators), but the challenges remain as important as ever.  This is why we 
are making this document publicly available. </p>

<h2> <a name="elasticity">Challenges in Elastic and Distributed Computing</a></h2>

<p> The current state of distributed computing is far from satisfying the 
requirements of real-world computing.  We give a brief overview of the 
research areas that must be advanced in order to achieve a fully elastic 
Internet, to make possible real-world computing applications.</p>

<p> <em>Data-intensive computing frameworks</em>.  Today's state of the art is 
based on a small number of scalable abstractions.  For example, Google's 
BigTable and MapReduce are just a few examples.  Other examples include 
scalable key-value databases, some of which can support transactions (e.g., 
Scalaris and Beernet) or just simple updates (e.g., Cassandra).  The question 
whether scalability can be achieved together with consistency is not yet 
answered for very large systems (1000s of nodes or more).  The problem of 
co-locating data and tasks is not yet solved satisfactorily.  For example, 
Hadoop requires slots with co-located data, where MPI tries to schedule tasks 
close to each other to increase inter-node bandwidth.  Communication 
requirements are dynamic and might change during the lifetime of a job.  In 
the current state of the art, solutions are limited and ad hoc.  For example, 
MapReduce can speculatively re-launch a task if it suspects it is a straggler.  
Mesos uses a combination of centralized/distributed scheduler to reduce 
allocation time of resources on clusters.  All these abstractions and tools 
are hard to use and combine together.  Development complexity is a limiting 
factor for real-world applications.  We must therefore raise the level of 
abstraction of data-intensive frameworks, defining high-level programming 
models and compiling them down to scalable abstractions and their run-time 
frameworks.  And as explained below, these frameworks must support large-scale 
machine learning algorithms.  The Flagship must also make it possible to 
combine abstractions, for example by defining common interchange formats.</p>

<p> <em>Fully elastic Internet</em>.  To reach the enormous resources required 
by real-world computing, the Flagship's goal is to extend elasticity to cover 
the whole Internet.  For example, this can be done by building elastic 
computing into peer-to-peer overlay networks and by building hybrids of 
clouds, grids, and peer-to-peer networks.  Clouds and grids remain useful 
because they provide large size with low internal latency, but for many tasks 
a smaller size may be satisfactory (e.g., cloud on a cluster) and a larger 
latency may be satisfactory (loosely coupled elastic computing).  Current 
elastic infrastructures (clouds) have been compared to electric utilities.  
[BRY2010] explains some of the ways that clouds are different from electric 
utilities: they have a faster pace of innovation, they are subject to 
fundamental limits (CAP theorem, latency and bandwidth limitations), they 
suffer from lock-in and lack of interoperability, and they have security 
concerns.  In addition, we note that elastic computing has a much more complex 
structure than elastic electricity distribution.  There are four basic forms 
of elastic computing, depending on whether computing power or storage is 
concerned, and on whether successive tasks are correlated or uncorrelated.  
All four forms are important and must be supported.  If the Internet is to 
become fully elastic, all these issues related to elasticity must be resolved 
satisfactorily. </p>

<p> <em>Performance of elasticity</em>. Real-world computing puts demands on 
the capacity of elastic computing that current systems cannot meet. The 
allocation and deallocation of elastic resources is currently much too slow 
(e.g., it can take minutes on Amazon EC2) and small scale (allocating up to 
tens of nodes is possible, but allocating more requires special contracts or 
is impossible, even though data centers may have thousands or more nodes 
available).  For realizing applications of real-world computing, it is easy to 
see that allocation times of fractions of a second are needed (e.g., for 
real-time language translation) and scales of thousands of nodes will be 
required (e.g., for lookup in the large databases and postprocessing).  Much 
research and development will be needed to achieve these levels of 
performance.  Some current projects are moving in this direction, e.g., the 
Mesos project is projected to allocate at the level of tens of seconds instead 
of minutes.  This is still two orders of magnitude below what is required in 
the Flagship.</p>

<p> <em>Scalability</em>. A scalable system is not just potentially large, it 
must also be long-lived.  The Flagship must catalyze research to study the 
long term behavior of scalable systems.  This is a fundamental issue that has 
only been addressed in limited ways, e.g., in software rejuvenation and 
removal of memory leaks [VAI2005].  The longevity of a system must be studied 
and solved in a fundamental manner.</p>

<p> <em>Beyond virtual machines</em>. Virtual machines provide isolation and 
custom computing environments, but they are much too coarse-grained.  For 
example, one of the reasons for the poor performance of elasticity is due to 
virtual machines.  We need to move away from full-fledged virtual machines 
toward more flexible forms of virtualization and customization.  VMs remain 
useful for hosting of services but not for data-intensive computing.  We need 
to explore the full spectrum of isolation models from OS processes to virtual 
machines.  Process isolation is not enough; VM isolation is too much.  Linux 
containers are a step in the right direction: they provide more isolation than 
processes (they include some resources) and are faster to allocate than 
virtual machines.</p>

<p> <em>Security and trust</em>. Real-world computing requires guarantees of a 
secure and trustworthy operational environment. Mechanisms that need to be 
explored include the use of Trusted Platform Modules (TPM) and the ability to 
provide fine-grained access and security controls across elastic platforms and 
applications. TPM have been developed to provide a hardware-based root for 
trust; however, despite its use in a variety of devices, we are far from 
reaching ubiquitous TPM and enabling trusted computing on virtual machines.  
Future fully elastic Internet may require TPM or a descendant of TPM, as well 
as virtual machines instrumented with security policies and running on TPMs.  
Another challenge is the ability to provide audit trails across elastic 
environments for regulatory compliance and digital forensic purposes.  
Regulatory compliance requires socio-legal and technical solutions. The 
Flagship will consider these research challenges, integrating and leveraging 
from security work developed by other communities such as trust computing, 
grids, clouds, and virtualization, among others. </p>

<p> <em>Distributed management</em>.  A federated cloud must be able to 
provision resources, so it needs an underlying management infrastructure with 
some global view.  According to the principles of distributed systems (i.e., 
locality and asynchrony are natural, global properties must be programmed, and 
given the high probability of faults in large systems, global coherence is not 
possible in a practical sense), the global view must tolerate some amount of 
incoherence.  Questions to be answered: What kind of global view is needed?  
What degree of coherency is right?  What is the right degree of abstraction?  
The system will also be subject to the usual problems of global behavior of 
scalable systems, i.e., phase changes, critical points, and fluctuations.  All 
these issues add to the problems mentioned before. </p>

<p> <em>Secure distributed scalable storage</em>.  Storage systems must be 
scalable.  Today's is only scalable inside data centers.  Scalable storage 
must be an Internet-wide service, like today we have reliable communications 
as an Internet-wide service (TCP/IP).  This does not exist today.  We need a 
distributed storage platform as a service. A secure distributed storage 
infrastructure (Platform as a service PaaS) that crosses administrative and 
geographical boundaries, and provides data migration/replication and data 
mobility to adapt to access patterns and network topology  with the goal of 
optimizing bandwidth consumption.</p>

<p> <em>Information-Centric Networking (ICN)</em>.  This is an important 
direction in networking research that aims for the networking infrastructure 
to work directly with information objects instead of just performing 
end-to-end communication.  This can make in-network storage, multiparty 
communication and publish/subscribe generally available without needing 
dedicated systems such as peer-to-peer overlays.  An important question being 
addressed in this research is whether an ICN architecture can enable new kinds 
of applications that are too complex for traditional networks.  The abilities 
that ICN can provide may be crucial for the Flagship goal of a fully elastic 
Internet.  The tensions between ICN and peer-to-peer clouds (as mentioned 
above) should be resolved in the Flagship. </p>

<h2> <a name="data">Challenges in data processing and machine learning</a> </h2>

<p> Scalable and elastic computing power and data storage is not sufficient 
for real-world computing.  It should be complemented with algorithms that are 
adequate for handling the high volumes of data and the elastic nature of the 
infrastructure.  Typically, current systems for scalable databases are only 
able to answer relatively simple queries.  Breakthroughs in several fields are 
needed for performing real-world tasks with real-world data.  These fields 
include algorithmic complexity (where recently some first successes are seen 
on matching patterns in large highly connected networks), scalable data 
stores, and problems related to scale and complexity in machine learning.</p>

<p> <em>Computational tractability</em>. For some classes of problems, solving 
them does not scale well with the problem size.  This is the case for the 
so-called NP-hard problems.  Nevertheless, throughout the last decades, steady 
progress has been made towards better and faster algorithms, both from a 
asymptotic complexity point of view (e.g. with fixed parameter tractability 
algorithms) and practically (with clever heuristics, which however in several 
cases need to be altered when the problem size is increased with orders of 
magnitude).  Further progress is needed on each of these fronts.  Moreover, 
further effort is needed to exploit these algorithms in reasoning engines.</p>

<p> <em>The curse of dimensionality</em>.  Machine learning has made enormous 
progress in the last 20 years, but there are still many unsolved problems.  
For example, a perennial problem in machine learning is called "the curse of 
dimensionality".  The basic problem can be summarized as follows.  The space 
of possible behaviors or features that must be learned is of extremely high 
dimensionality.  The meaning of "extremely high" is a function of time; with 
today's advanced algorithms it means several tens of thousands of dimensions.  
The data samples are vectors in this high-dimensional space.  For example, 
images such as faces are very high dimensional.  To successfully learn from 
this data, ML algorithms must reduce its high dimensionality to a 
lower-dimensional set of crucial features.  Paradoxically ML is a victim of 
its success: as higher and higher dimensionalities can be handled successfully 
through more sophisticated techniques, the demand for handling even higher 
dimensionalities increases [VER2003].  As handling of faces becomes more 
sophisticated and takes into account more detail, they are considered as 
having more and more dimensions. </p>

<p> <em>Large-scale machine learning</em>.  There are two orthogonal "scales"
in machine learning: the size of the data set (number of samples and size of 
each sample) and the size of the result space (e.g., number of features in a 
classification problem or number of actions in a reinforcement learning 
problem).  The latter leads to the curse of dimensionality discussed above.  
Large scale machine learning focuses primarily on handling the former, i.e., 
data set scalability, using parallel and distributed computing.  The NIPS 2009 
Workshop on that topic has made predictions for the next decade [LSL2009].  
Currently only a limited number of computational paradigms are efficiently 
parallelized (e.g., Google's MapReduce, Yahoo!'s Hadoop, Microsoft's Dryad, 
and streaming architectures such as Yahoo!'s S4).  The workshop organizers 
predict that we will see a convergence of systems technologies and suitable 
algorithms over the next decade and that it is highly likely that within a 
decade all widely used machine learning algorithms will be parallel.  This 
trend is expected to play a major role in the Flagship.</p>

<p> <em>Deep learning</em>.  Deep learning posits that learning complicated 
functions requires determining multiple layers of nonlinear operations, such 
as neural nets with many hidden layers or complex propositional formulae with 
many sub-formulae [BEN2009].  These layers are important because they 
correspond to high-level abstractions, closer to human concepts.  The focus of 
deep architecture learning is to automatically discover such abstractions, 
from low level features to high level concepts.  Ideally, this should be done 
with as little human effort as possible.  This is very difficult and requires 
conceptual breakthroughs.  So far, there have been two major breakthroughs: 
(1) the original breakthrough in supervised training of multiple layer neural 
networks, the backpropagation algorithm [RUM1986] (for two or three levels), 
(2) training of deep multiple layer neural networks (for greater than three 
levels) with an algorithm that greedily trains one layer at a time (e.g., Deep 
Belief Networks, which are trained using the unsupervised Restricted Boltzmann 
Machines [HIN2006]).  The principle is to guide the training of intermediate 
levels using unsupervised learning, which can be performed locally at each 
level.  The ramifications of the second breakthrough could play a major role 
in the Flagship, as the principles underlying it are generalized and applied 
widely<sup><a href="#foot1">1</a></sup><a name="foot1back"></a>.</p>

<p> <em>Generalized n-body problems (GNPs)</em>.  GNPs consist of problems 
that are defined in terms of large numbers of pairwise interactions [GRA2000].  
It turns out that many problems in physical science and data analysis are of 
this type.  This is why it is important to parallelize these problems.  They 
may play an important role in real-world computing.</em>

<p> <em>Security in machine learning</em>.  In the Flagship, ML will be scaled 
up and used for complex tasks.  In this setting, the problems of security 
becomes critical and must be solved [LAS2010,BAR2010].  We observe first that 
ML is used as a tool for computer security (e.g., it is already widely used 
for spam detection and network intrusion detection).  But security is much 
more important as personal information becomes more and more embedded in ML 
applications.  We conclude that large ML systems used for real-world 
applications should offer desirable secure behavior.  For example, they might 
have a requirement for being non-eavesdroppable or for non-divulgence to third 
parties.  Sensitive personal data is increasingly digitally aggregated and 
stored.  The ML algorithms used to detect patterns in real databases must 
maintain the privacy of individuals.  ML systems also have a requirement for 
correct behavior (integrity) and availability.  All these requirements will 
influence the ML algorithms and implementation used.  They will influence both 
the learning and query phases, which are both liable to attacks.  The Flagship 
must therefore consider the security aspect of ML algorithms and their 
implementations, and examine how to direct the research in secure machine 
learning for large scales.</p>

<h2><a name="application">Application Grand Challenges for Real-World Computing</a></h2>

<p> We identify the following nonexhaustive list of high-level services that 
real-world computing can provide and that can be used by many applications.  
We consider these services as <em>challenges</em> for real-world computing.  
One of the quantitative measures of success of real-world computing will be 
how many of these challenges can be met in realistic ways.</p>

<ol>

<li> <em>Full media interchangeability</em>.  This is the real-time 
translation of human languages between textual, audio, and video forms.  The 
complexity of human languages and their expression will be tamed by using 
learning algorithms based on large corpora of existing language information, 
possibly using deep learning algorithms to perform long-distance 
transformations on the sequence of speech acts.  This ability is called 
<em>Total Transparent Processing</em> by Alfred Spector, VP of Google Research 
[SPE2010].  </li>

<li> <em>Knowledge extraction from raw data</em>.  This is the ability to 
extract useful knowledge from the vast body of raw digital content (text, 
audio, video, sensor data).  The complexity of the raw digital content will be 
tamed by using learning algorithms based on large corpora, complemented by 
algorithms for inferencing, cleaning data and putting it into canonical forms 
(when possible).  A first step toward this ability is provided by the Wolfram 
Alpha Computational Knowledge Engine [WOL2010], which is able to compute with 
meaningful information.  This engine is currently limited to free-form text 
and its inferencing ability is fragile.  Going beyond this ability requires 
progress in several areas: learning, inferencing, computing resources, raw 
data processing.  This is exactly the vision of the Flagship. </li>

<li> <em>Creative problem solving ("tamed brute force search")</em>. This is 
the ability to combine information to provide useful solutions to problems 
specified by humans.  The combinatorial explosion of the number of 
combinations of solution elements (exhaustive search) will be tamed by 
learning algorithms that learn to distinguish the useful paths from the 
useless ones.  Brute force search becomes practical when guided by large-scale 
learning algorithms. </li>

<li> <em>Expert guidance (goal-oriented augmented reality)</em>.  This is the 
ability to guide human beings interactively to help them perform a complex 
knowledge-intensive task.  The management of real-time contingencies (reacting 
to human actions) will be done by learning algorithms based on large corpora 
of successful expert activities.  For example, car repair manuals will be 
replaced by a car repair assistant, which is a real-world application that 
interactively guides the human by processing the video and audio of the 
human's actions in real time. </li>

<li> <em>Continuous fluid interaction</em>. Future human-computer interfaces 
(HCI) will not make detours through text or WIMP (windowing interfaces), but 
interface directly at a human level with detailed immersive reality.  Because 
of the detailed complexity of human interaction, these interfaces will not be 
programmed directly (as is the case with most of today's experiments in 
virtual reality), but will be learned from example and with feedback from 
users.  ML is already being used in the HCI community, e.g., the SERENOA 
project (FP7) is developing context-sensitive service front ends that use ML 
to adapt to changes in context in a continuous manner [SER2010]. </li>

</ol>

<p> We call <em>learning services</em> the above services together with the 
large scale scalable ML services that implement them.  It is important to note 
that these services can be applied to many application domains.  In the 
Flagship we will explicitly target a subset of these domains and we will 
encourage development in the others. </p>

<h2>References</h2>

<p>[BAR2010] Marco Barreno, Blaine Nelson, Anthony D. Joseph, and J.D. Tygar.
"The security of machine learning." J. Mach. Learn (2010) 81:121-148.</p>

<p>[BEN2009] Yoshua Bengio. <em>Learning Deep Architectures for AI</em>.  
Foundations and Trends(r) in Machine Learning 2(1), 2009, pp. 1-127.</p>

<p>[BRY2010] Erik Brynjolfsson, Paul Hofmann, and John Jordan. "Cloud
Computing and Electricity: Beyond the Utility Model," CACM 53(5), May 2010, 
pp. 32-34.</p>

<p>[GRA2000] Alexander G. Gray and Andrew W. Moore. " 'N-Body' Problems in
Statistical Learning," NIPS, volume 4, 2000, pp. 521-527.</p>

<p>[HIN2006] G. E. Hinton, S. Osindero, and Y. Teh, "A fast learning
algorithm for deep belief nets," Neural Computation, vol. 18, 2006, pp. 
1527-1554.</p>

<p>[LAS2010] Pavel Laskov and Richard Lippmann. "Machine learning in
adversarial environments." Editorial introduction, special issue on security 
in machine learning. J. Mach. Learn. (2010) 81:115-119.</p>

<p>[LSL2010] Large-Scale Machine Learning: Parallelism and Massive Datasets.
NIPS 2009 Workshop, Dec. 11, 2009.</p>

<p>[RUM1986] David E. Rumelhart, Geoffrey E. Hinton, and Ronald J. Williams.
"Learning Internal Representations by Error Propagation," Parallel Distributed 
Processing: Explorations in the Microstructure  of Cognition. Vol. 1: 
Foundations. Cambridge, MA: Bradford Books/MIT Press, 1986 (Technical Report 
1985).</p>

<p>[SER2010] SERENOA: Multidimensional Context-Aware Adaptation of Service
Front Ends. STREP, FP7, Sep. 2010- Aug. 2013. See: www.serenoa-fp7.eu.</p>

<p>[SPE2010] Alfred Spector. "Rapid Advances in Computer Science and
Opportunities for Society," European CS Presentation, Oct. 2010.</p>

<p>[VAI2005] Kalyanaraman Vaidyanathan and Kishor S. Trivedi. "A Comprehensive 
Model for Software Rejuvenation," IEEE Transactions on Dependable and Secure 
Computing (2005) 2(2):124-137.</p>

<p>[VER2003] Michel Verleysen. "Learning high-dimensional data." Limitations
and Future Trends in Neural Computation, IOS Press, 2003, pp. 141-162.</p>

<p>[WOL2010] <a href="http://www.wolframalpha.com">Wolfram Alpha LLC</a>.  
Wolfram Alpha Computational Knowledge Engine, 2010.</p>

<h2> Footnote </h2>

<ol>

<li> <a name="foot1"></a> We note that there is skepticism in part of the 
ML community on the ultimate usefulness of deep learning techniques. However, 
given the potential of deep learning for bringing the level of 
conceptualization closer to the human level, which is one of the goals of 
real-world computing, we conclude that it must be examined in the 
Flagship. <a href="#foot1back">back</a></li>

</ol>

</div> <!-- end maincontent -->

<?php
	makeFooter();
?>


