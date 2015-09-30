#include <ruby.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

// The one and only lookup table.
int HR[32487834];
const char * const HAND_CATEGORY_KEYS[] = { "invalid_hand", "high_card", "one_pair", "two_pairs", "three_of_a_kind", "straight", "flush", "full_house", "four_of_a_kind", "straight_flush" };

/******************************************************************************/
/*  These are pure C functions and should not deal with any Ruby values or    */
/*  conversions.                                                              */
/******************************************************************************/

char* rb_get_gem_path();

char* concat( char* first, char* second ){
  size_t first_length = strlen( first );
  size_t second_length = strlen( second );
  int both_length = first_length + second_length + 1;
  char* both = (char*) malloc( both_length * sizeof( char ));

  strcpy( both, first );
  strcat( both, second );

  return both;
}

char* c_prefix_with_gem_path( char* file_name ){
  char* path = rb_get_gem_path();

  return concat( path, file_name );
}

char* hand_category_key( int index ){
  size_t length = strlen( HAND_CATEGORY_KEYS[ index ]);
  char* name = (char*) malloc( length * sizeof( char ));

  strcpy( name, HAND_CATEGORY_KEYS[ index ]);

  return name;
}

char* c_hand_category_key( int index ){
  size_t length = strlen( HAND_CATEGORY_KEYS[ index ]);
  char* key = (char*) malloc( length * sizeof( char ));

  strcpy( key, HAND_CATEGORY_KEYS[ index ]);

  return key;
}

void convert_ruby_array_to_c_array( VALUE rb_cards, int *c_cards, int length ){
  int i;

  for( i = 0; i < length; i++ ){
    c_cards[ i ] = NUM2INT( rb_ary_entry( rb_cards, i ));
  }
}

int c_rank_7_card_hand( int* cards ){
  int p = HR[53 + *cards++];
  p = HR[p + *cards++];
  p = HR[p + *cards++];
  p = HR[p + *cards++];
  p = HR[p + *cards++];
  p = HR[p + *cards++];
  p = HR[p + *cards++];
  return p;
}

int c_rank_6_card_hand( int* cards ){
  int p = HR[53 + *cards++];
  p = HR[p + *cards++];
  p = HR[p + *cards++];
  p = HR[p + *cards++];
  p = HR[p + *cards++];
  p = HR[p + *cards++];
  return HR[p];
}

int c_rank_5_card_hand( int* cards ){
  int p = HR[53 + *cards++];
  p = HR[p + *cards++];
  p = HR[p + *cards++];
  p = HR[p + *cards++];
  p = HR[p + *cards++];
  return HR[p];
}

int c_rank_hand( int* cards, int length ){
  int result;

  switch( length ){
    case 5 :
       result = c_rank_5_card_hand( cards );
       break;
    case 6 :
       result = c_rank_6_card_hand( cards );
       break;
    default :
       result = c_rank_7_card_hand( cards );
  }

  return result;
}

int c_load_lut( char* path ){
  memset( HR, 0, sizeof( HR ));

  FILE * fin = fopen( path, "rb" );

  if( fin == NULL ){
    return -1;
  }

  size_t bytesread = fread( HR, sizeof( HR ), 1, fin );
  fclose( fin );

  return 0;
}

/******************************************************************************/
/*  These are Ruby functions, in C, and deal with the convertion of values to */
/*  and from the two contexts.                                                */
/******************************************************************************/

VALUE rb_rank( VALUE klass, VALUE rb_num_ary ){
  int length = RARRAY_LEN( rb_num_ary );
  int c_cards[ length ];

  convert_ruby_array_to_c_array( rb_num_ary, c_cards, length );

  return INT2NUM( c_rank_hand( c_cards, length ));
}

VALUE rb_category( VALUE klass, VALUE rb_rank ){
  int rank = NUM2INT( rb_rank );
  int category = rank >> 12;

  return INT2NUM( category );
}

VALUE rb_rank_in_category( VALUE klass, VALUE rb_rank ){
  int rank = NUM2INT( rb_rank );
  int rank_in_category = rank & 0x00000FFF;

  return INT2NUM( rank_in_category );
}

VALUE rb_category_key( VALUE klass, VALUE rb_rank ){
  int rank = NUM2INT( rb_rank );
  int category = rank >> 12;
  
  char* key = c_hand_category_key( category );

  return rb_str_new2( key );
}

VALUE rb_explain( VALUE klass, VALUE rb_rank ){
  int rank = NUM2INT( rb_rank );
  int category = rank >> 12;
  int rank_in_category = rank & 0x00000FFF;
  VALUE category_key = rb_category_key( klass, rb_rank );

  VALUE result = rb_sprintf( "The hand is a %"PRIsVALUE"\nRank: %d Category: %d Rank in category: %d", category_key, rank, category, rank_in_category );

  return result;
}

char* rb_get_gem_path(){
  VALUE cHandRank = rb_const_get(rb_cObject, rb_intern("HandRank"));
  ID sym_mymodule = rb_intern( "HOME" );
  VALUE home = rb_const_get( cHandRank, sym_mymodule );
  return StringValueCStr( home );
}

void rb_load_lut(){
  char* path =  c_prefix_with_gem_path( "ranks.data" );
  if( c_load_lut( path ) == -1 ){
    rb_raise( rb_eIOError, "Could not open the data file at %s%s\n         Please go to the folder and manually unzip ranks.data.zip to solve this problem.", rb_get_gem_path(), "ranks.data" );
    exit( 1 );
  }
}

/******************************************************************************/
/*  This is the "magical" setup function, the main entry point, that is       */
/*  responsible for exporting our C function to the Ruby context.             */
/******************************************************************************/

void Init_hand_rank( void ){

  rb_load_lut();

  VALUE cHandRank = rb_const_get(rb_cObject, rb_intern("HandRank"));

  rb_define_singleton_method( cHandRank, "rank", rb_rank, 1 );
  rb_define_singleton_method( cHandRank, "category", rb_category, 1 );
  rb_define_singleton_method( cHandRank, "rank_in_category", rb_rank_in_category, 1 );
  rb_define_singleton_method( cHandRank, "category_key", rb_category_key, 1 );
  rb_define_singleton_method( cHandRank, "explain", rb_explain, 1 );
}