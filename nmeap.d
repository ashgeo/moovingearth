/* Converted to D from nmeap.h by htod */
module nmeap;
/*
Copyright (c) 2005, David M Howard (daveh at dmh2000.com)
All rights reserved.

This product is licensed for use and distribution under the BSD Open Source License.
see the file COPYING for more details.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, 
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT 
OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; 
OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 

*/

//C     #ifndef __NMEAP_H__
//C     #define __NMEAP_H__

//C     #ifdef __cplusplus
//C     extern "C" {
//C     #endif

/* 
============================================
COMPILE TIME CONFIGURATION CONSTANTS
============================================
*/

/* these constants affect the size of the context object. tweak them as desired but know what you are doing */

/** maximum number of sentence parsers supported */
//C     #define NMEAP_MAX_SENTENCES            8
const NMEAP_MAX_SENTENCES = 8;
/** length of sentence name. leave this at 5 unless you really know what you are doing */
//C     #define NMEAP_MAX_SENTENCE_NAME_LENGTH 5
const NMEAP_MAX_SENTENCE_NAME_LENGTH = 5;
/** max length of a complete sentence. the standard says 82 bytes, but its probably better to go at least 128 since
 * some units don't adhere to the 82 bytes especially for proprietary sentences */
//C     #define NMEAP_MAX_SENTENCE_LENGTH      255
const NMEAP_MAX_SENTENCE_LENGTH = 255;
/** max tokens in one sentence. 24 is enough for any standard sentence */
//C     #define NMEAP_MAX_TOKENS               24
const NMEAP_MAX_TOKENS = 24;

/* predefined message ID's */

/* GGA MESSAGE ID */
//C     #define NMEAP_GPGGA 1
const NMEAP_GPGGA = 1;

/* RMC MESSAGE ID */
//C     #define NMEAP_GPRMC 2
const NMEAP_GPRMC = 2;

/** user defined parsers should make ID numbers using NMEAP_USER as the base value, plus some increment */
//C     #define NMEAP_USER  100
const NMEAP_USER = 100;
/* forward references */
//C     struct nmeap_context;
//C     struct nmeap_sentence;

/* 
============================================
CALLOUTS
============================================
*/

/**
 * sentence callout function type
 * a callout is fired for each registered sentence type
 * the callout gets the object context and a pointer to sentence specific data.
 * the callout must cast the 'sentence_data' to the appropriate type for that callout
 * @param context			nmea object context
 * @param sentence_data		sentence specific data
*/
 
//C     typedef void (*nmeap_callout_t)(struct nmeap_context *context,void *sentence_data,void *user_data);
extern (C):
alias void  function(nmeap_context *context, void *sentence_data, void *user_data)nmeap_callout_t;

/**
 * sentence parser function type
 * stored in the object context and called internally when the sentence name matches
 * the specified value
 * the callout gets the object context and a pointer to sentence specific data.
 * the callout must cast the 'sentence_data' to the appropriate type for that callout
 * @param context			nmea object context
 * @param sentence_data		sentence specific data
 * @return id of sentence  (each sentence parser knows its own ID)
*/
 
//C     typedef int (*nmeap_sentence_parser_t)(struct nmeap_context *context,struct nmeap_sentence *sentence);
alias int  function(nmeap_context *context, nmeap_sentence *sentence)nmeap_sentence_parser_t;


/* ==== opaque types === */
//C     #include "nmeap_def.h"
/*
Copyright (c) 2005, David M Howard (daveh at dmh2000.com)
All rights reserved.

This product is licensed for use and distribution under the BSD Open Source License.
see the file COPYING for more details.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, 
OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT 
OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; 
OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, 
WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE 
OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 

*/

//C     #ifndef __NMEAP_DEF_H__
//C     #define __NMEAP_DEF_H__

/**
 * context for a single sentence 
 */
//C     typedef struct nmeap_sentence {
//C         ubyte                    name[NMEAP_MAX_SENTENCE_NAME_LENGTH + 1];
//C     	int                     id;
//C         nmeap_sentence_parser_t parser;
//C         nmeap_callout_t         callout;
//C         void                   *data;
//C     } nmeap_sentence_t;
struct nmeap_sentence
{
    ubyte [6]name;
    int id;
    nmeap_sentence_parser_t parser;
    nmeap_callout_t callout;
    void *data;
}
alias nmeap_sentence nmeap_sentence_t;

/** 
 * parser context
 */
//C     struct nmeap_context {
	/** support up to 8 sentences */
//C     	nmeap_sentence_t sentence[NMEAP_MAX_SENTENCES];		/* sentence descriptors */
//C     	int              sentence_count;						/* number of initialized descriptors */
	
	/** sentence input buffer */
//C     	ubyte             input[NMEAP_MAX_SENTENCE_LENGTH + 1];	 /* input line buffer */
//C     	int              input_count;	                        /* index into 'input */
//C     	int              input_state;	                        /* current lexical scanner state */
//C     	ubyte             input_name[6];                        /* sentence name */
//C     	ubyte             icks; 			                        /* input checksum    */
//C     	ubyte             ccks; 			                        /* computed checksum */
	
	/* tokenization */
//C     	ubyte            *token[NMEAP_MAX_TOKENS];              /* list of delimited tokens */
//C     	int              tokens;							     /* list of tokens */
	
	/** errors and debug. optimize these as desired */
//C     	unsigned long    msgs;    /* count of good messages */
//C     	unsigned long    err_hdr; /* header error */							
//C     	unsigned long    err_ovr; /* overrun error */
//C     	unsigned long    err_unk; /* unknown error */
//C     	unsigned long    err_id;  /* bad character in id */
//C     	unsigned long    err_cks; /* bad checksum */
//C     	unsigned long    err_crl; /* expecting cr or lf, got something else */
//C     	ubyte             debug_input[NMEAP_MAX_SENTENCE_LENGTH + 1];	 /* input line buffer for debug */
	
	/** opaque user data */
//C     	void *user_data;
//C     };
struct nmeap_context
{
    nmeap_sentence_t [8]sentence;
    int sentence_count;
    ubyte [256]input;
    int input_count;
    int input_state;
    ubyte [6]input_name;
    ubyte icks;
    ubyte ccks;
    ubyte *[24]token;
    int tokens;
    uint msgs;
    uint err_hdr;
    uint err_ovr;
    uint err_unk;
    uint err_id;
    uint err_cks;
    uint err_crl;
    ubyte [256]debug_input;
    void *user_data;
}

//C     typedef struct nmeap_context nmeap_context_t;
alias nmeap_context nmeap_context_t;

//C     #endif /* __NMEAP_DEF_H__ */ 


/* 
============================================
STANDARD SENTENCE DATA STRUCTURES
============================================
*/

/** extracted data from a GGA message */
//C     struct nmeap_gga {
//C     	double        latitude;
//C     	double        longitude;
//C     	double        altitude;
//C     	unsigned long time;
//C     	int           satellites;
//C     	int           quality;
//C     	double        hdop;
//C     	double        geoid;
//C     };
struct nmeap_gga
{
    double latitude;
    double longitude;
    double altitude;
    uint time;
    int satellites;
    int quality;
    double hdop;
    double geoid;
}
//C     typedef struct nmeap_gga nmeap_gga_t;
alias nmeap_gga nmeap_gga_t;

/** extracted data from an RMC message */
//C     struct nmeap_rmc {
//C     	unsigned long time;
//C     	ubyte          warn;
//C     	double        latitude;
//C     	double        longitude;
//C     	double        speed;
//C     	double        course;
//C     	unsigned long date;
//C     	double        magvar;
//C     };
struct nmeap_rmc
{
    uint time;
    ubyte warn;
    double latitude;
    double longitude;
    double speed;
    double course;
    uint date;
    double magvar;
}

//C     typedef struct nmeap_rmc nmeap_rmc_t;
alias nmeap_rmc nmeap_rmc_t;

/* 
============================================
METHODS
============================================
*/

/**
 * initialize an NMEA parser. call this function to initialize a user allocated context object
 * @param context 		nmea object context. allocated by user statically or dynamically.
 * @param user_data 	pointer to user defined data
 * @return 0 if ok, -1 if initialization failed
 */
//C     int nmeap_init(nmeap_context_t *context,void *user_data);
int  nmeap_init(nmeap_context_t *context, void *user_data);

/**
 * register an NMEA sentence parser
 * @param context 		   nmea object context
 * @param sentence_name    string matching the sentence name for this parser. e.g. "GPGGA". not including the '$'
 * @param sentence_parser  parser function for this sentence
 * @param sentence_callout callout triggered when this sentence is received and parsed. 
 *                         if null, no callout is triggered for this sentence
 * @param sentence_data    user allocated sentence specific data defined by the application. the parser uses
                           this data item to store the extracted data. This data object needs to persist over the life
						   of the parser, so be careful if allocated on the stack. 
 * @return 0 if registered ok, -1 if registration failed
 */
//C     int nmeap_addParser(nmeap_context_t         *context,
//C     					 const ubyte             *sentence_name,
//C     					 nmeap_sentence_parser_t sentence_parser,
//C     					 nmeap_callout_t         sentence_callout,
//C     					 void                   *sentence_data
//C     					 );
int  nmeap_addParser(nmeap_context_t *context, ubyte *sentence_name, nmeap_sentence_parser_t sentence_parser, nmeap_callout_t sentence_callout, void *sentence_data);

/** 
 * parse a buffer of nmea data.
 * @param context 		   nmea object context
 * @param buffer          buffer of input characters
 * @param length          [in,out] pointer to length of buffer. on return, contains number of characters not used for
 *                        the current sentence
 * @return -1 if error, 0 if the data did not complete a sentence, sentence code if a sentence was found in the stream
 */
//C     int nmeap_parseBuffer(nmeap_context_t *context,const ubyte *buffer,int *length);
int  nmeap_parseBuffer(nmeap_context_t *context, ubyte *buffer, int *length);

/** 
 * parse one character of nmea data.
 * @param context 		   nmea object context
 * @param ch              input character
 * @return -1 if error, 0 if the data did not complete a sentence, sentence code if a sentence was found in the stream  
 */
//C     int nmeap_parse(nmeap_context_t *context,ubyte ch);
int  nmeap_parse(nmeap_context_t *context, ubyte ch);


/** 
 * built-in parser for GGA sentences.
 * @param context 		   nmea object context
 * @param sentence         sentence object for this parser
  */
//C     int nmeap_gpgga(nmeap_context_t *context,nmeap_sentence_t *sentence);
int  nmeap_gpgga(nmeap_context_t *context, nmeap_sentence_t *sentence);

/** 
 * built-in parser for RMC sentences.
 * @param context 		   nmea object context
 * @param sentence         sentence object for this parser
 */
//C     int nmeap_gprmc(nmeap_context_t *context,nmeap_sentence_t *sentence);
int  nmeap_gprmc(nmeap_context_t *context, nmeap_sentence_t *sentence);

/**
 * extract latitude from 2 tokens in ddmm.mmmm,h format.
 * @param plat pointer to token with numerical latitude
 * @param phem pointer to token with hemisphere
 * @return latitude in degrees and fractional degrees
 */
//C     double nmeap_latitude(const ubyte *plat,const ubyte *phem);
double  nmeap_latitude(ubyte *plat, ubyte *phem);


/**
 * extract longitude from 2 tokens in ddmm.mmmm,h format.
 * @param plat pointer to token with numerical longitude
 * @param phem pointer to token with hemisphere
 * @return longitude in degrees and fractional degrees
 */
//C     double nmeap_longitude(const ubyte *plat,const ubyte *phem);
double  nmeap_longitude(ubyte *plat, ubyte *phem);

//C     #ifdef __cplusplus
//C     } // extern C
//C     #endif


//C     #endif

