Module mma
        Implicit None
        Save
Contains
        Subroutine mma_save_real_tensor(tensor_name, file_name, variable_name)
                Implicit None
                Integer::ierror, i, j, k
                Real, Intent(In), Dimension(:, :, :)::tensor_name
                Character(len=*), Intent(In)::file_name
                Character(len=*), Intent(In), Optional::variable_name
                Open (Unit=19, File=file_name, Status='replace', Iostat=ierror)
                ifhasvariablename: If (Present(variable_name)) Then
                        Write (19, *) variable_name, '=', '{'
                        writeintofile: Do i = 1, Size(tensor_name(:, 1, 1))
                                Write (19, *) '{'
                                writeintofilej: Do j = 1, Size(tensor_name(1, :, 1))
                                        Write (19, *) '{'
                                        writeintofilek: Do k = 1, Size(tensor_name(1, 1, :))
                                                lastterm: If (k /= Size(tensor_name(1, 1, :))) Then
                                                        Write (19, "(F10.6)") tensor_name(i, j, k)
                                                        Write (19, *) ','
                                                Else
                                                        Write (19, "(F10.6)") tensor_name(i, j, k)
                                                End If lastterm
                                        End Do writeintofilek
                                        Write (19, *) '}'
                                        iiflastt: If (j /= Size(tensor_name(1, :, 1))) Then
                                                Write (19, *) ','
                                        End If iiflastt
                                End Do writeintofilej
                                Write (19, *) '}'
                                iflast: If (i /= Size(tensor_name(:, 1, 1))) Then
                                        Write (19, *) ','
                                End If iflast
                        End Do writeintofile
                        Write (19, *) '}'
                Else
                        Write (19, *) file_name, '=', '{'
                        writeintofile2: Do i = 1, Size(tensor_name(:, 1, 1))
                                Write (19, *) '{'
                                writeintofilej2: Do j = 1, Size(tensor_name(1, :, 1))
                                        Write (19, *) '{'
                                        writeintofilek2: Do k = 1, Size(tensor_name(1, 1, :))
                                                lastterm2: If (k /= Size(tensor_name(1, 1, :))) Then
                                                        Write (19, "(F10.6)") tensor_name(i, j, k)
                                                        Write (19, *) ','
                                                Else
                                                        Write (19, "(F10.6)") tensor_name(i, j, k)
                                                End If lastterm2
                                        End Do writeintofilek2
                                        Write (19, *) '}'
                                        iiflast2: If (j /= Size(tensor_name(1, :, 1))) Then
                                                Write (19, *) ','
                                        End If iiflast2
                                End Do writeintofilej2
                                Write (19, *) '}'
                                iflast2: If (i /= Size(tensor_name(:, 1, 1))) Then
                                        Write (19, *) ','
                                End If iflast2
                        End Do writeintofile2
                        Write (19, *) '}'
                End If ifhasvariablename

                Close (Unit=19)
                Write (*, *) 'Write Tensor into File "', file_name, '" Successfully!'
        End Subroutine mma_save_real_tensor

        Subroutine mma_save_real_matrix(matrix_name, file_name, variable_name)
                Implicit None
                Integer::ierror, i, j
                Real, Intent(In), Dimension(:, :)::matrix_name
                Character(len=*), Intent(In)::file_name
                Character(len=*), Intent(In), Optional::variable_name
                Open (Unit=19, File=file_name, Status='replace', Iostat=ierror)
                ifhasvariablename: If (Present(variable_name)) Then
                        Write (19, *) variable_name, '=', '{'
                        writeintofile: Do i = 1, Size(matrix_name(:, 1))
                                Write (19, *) '{'
                                writeintofilej: Do j = 1, Size(matrix_name(1, :))
                                        lastterm: If (j /= Size(matrix_name(1, :))) Then
                                                Write (19, "(F10.6)") matrix_name(i, j)
                                                Write (19, *) ','
                                        Else
                                                Write (19, "(F10.6)") matrix_name(i, j)
                                        End If lastterm
                                End Do writeintofilej
                                Write (19, *) '}'
                                iflast: If (i /= Size(matrix_name(:, 1))) Then
                                        Write (19, *) ','
                                End If iflast
                        End Do writeintofile
                        Write (19, *) '}'
                Else
                        Write (19, *) file_name, '=', '{'
                        writeintofile2: Do i = 1, Size(matrix_name(:, 1))
                                Write (19, *) '{'
                                writeintofilej2: Do j = 1, Size(matrix_name(1, :))
                                        lastterm2: If (j /= Size(matrix_name(1, :))) Then
                                                Write (19, "(F10.6)") matrix_name(i, j)
                                                Write (19, *) ','
                                        Else
                                                Write (19, "(F10.6)") matrix_name(i, j)
                                        End If lastterm2
                                End Do writeintofilej2
                                Write (19, *) '}'
                                iflast2: If (i /= Size(matrix_name(:, 1))) Then
                                        Write (19, *) ','
                                End If iflast2
                        End Do writeintofile2
                        Write (19, *) '}'
                End If ifhasvariablename

                Close (Unit=19)
                Write (*, *) 'Write Matrix into File "', file_name, '" Successfully!'
        End Subroutine mma_save_real_matrix

        Subroutine mma_save_int_matrix(matrix_name, file_name, variable_name)
                Implicit None
                Integer::ierror, i, j
                Integer, Intent(In), Dimension(:, :)::matrix_name
                Character(len=*), Intent(In)::file_name
                Character(len=*), Intent(In), Optional::variable_name
                Open (Unit=19, File=file_name, Status='New', Iostat=ierror)
                ifhasvariablename: If (Present(variable_name)) Then
                        Write (19, *) variable_name, '=', '{'
                        writeintofile: Do i = 1, Size(matrix_name(:, 1))
                                Write (19, *) '{'
                                writeintofilej: Do j = 1, Size(matrix_name(1, :))
                                        lastterm: If (j /= Size(matrix_name(1, :))) Then
                                                Write (19, *) matrix_name(i, j), ','
                                        Else
                                                Write (19, *) matrix_name(i, j)
                                        End If lastterm
                                End Do writeintofilej
                                Write (19, *) '}'
                                iflast: If (i /= Size(matrix_name(:, 1))) Then
                                        Write (19, *) ','
                                End If iflast
                        End Do writeintofile
                        Write (19, *) '}'
                Else
                        Write (19, *) file_name, '=', '{'
                        writeintofile2: Do i = 1, Size(matrix_name(:, 1))
                                Write (19, *) '{'
                                writeintofilej2: Do j = 1, Size(matrix_name(1, :))
                                        lastterm2: If (j /= Size(matrix_name(1, :))) Then
                                                Write (19, *) matrix_name(i, j), ','
                                        Else
                                                Write (19, *) matrix_name(i, j)
                                        End If lastterm2
                                End Do writeintofilej2
                                Write (19, *) '}'
                                iflast2: If (i /= Size(matrix_name(:, 1))) Then
                                        Write (19, *) ','
                                End If iflast2
                        End Do writeintofile2
                        Write (19, *) '}'
                End If ifhasvariablename

                Close (Unit=19)
                Write (*, *) 'Write Matrix into File "', file_name, '" Successfully!'
        End Subroutine mma_save_int_matrix
End Module mma

!Program MAIN
!       Use mathematica
!      Implicit None
!     Real, Dimension(2, 3)::te = [1, 1, 2, 2, 3, 3]
!    Call save_real_matrix(te, 'va')
!End Program MAIN
